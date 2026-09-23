// Docker + database helpers shared by setup (via db.js), start.js and db.js.
const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");
const { ROOT, loadEnv, setLocal } = require("./env");
const { isFree, findFree, whoHas } = require("./ports");

const WIN = process.platform === "win32";
const MAC = process.platform === "darwin";
const CONTAINER = "hackalem-db";
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// On Linux, a fresh install may need sudo until the user re-logs into the docker group.
let prefix = [];
let composeVars = loadEnv();
function docker(args, opts = {}) {
  const [cmd, ...rest] = [...prefix, "docker", ...args];
  return spawnSync(cmd, rest, {
    cwd: ROOT,
    encoding: "utf8",
    maxBuffer: 512 * 1024 * 1024,
    ...opts,
    // Resolved values (.env + .env.local + shell) override what Compose reads from .env.
    env: { ...process.env, ...composeVars, ...(opts.env || {}) },
  });
}

function daemonUp() {
  if (docker(["info"], { stdio: "ignore" }).status === 0) return true;
  if (!WIN && !MAC && spawnSync("sudo", ["-n", "docker", "info"], { stdio: "ignore" }).status === 0) {
    prefix = ["sudo"];
    return true;
  }
  return false;
}

function launchDaemon() {
  if (MAC) spawnSync("open", ["-a", "Docker"]);
  else if (WIN) {
    const exe = "C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe";
    if (fs.existsSync(exe)) spawnSync("cmd.exe", ["/c", "start", "", exe]);
  } else spawnSync("sudo", ["systemctl", "start", "docker"], { stdio: "inherit" });
}

// Runs scripts/windows/docker-doctor.ps1 (Windows only) and returns its exit code.
function doctor(mode, stdio = "inherit", ...extra) {
  const script = path.join(ROOT, "scripts", "windows", "docker-doctor.ps1");
  return spawnSync("powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", script, mode, ...extra], { stdio }).status;
}

async function ensureDocker(log = console.log) {
  if (spawnSync("docker", ["--version"], { stdio: "ignore", shell: WIN }).status !== 0) {
    return `Docker is not installed — run ${WIN ? "setup.cmd" : "./setup.sh"} first.`;
  }
  if (daemonUp()) return null;
  const VIRT_FIX = "Docker can't run until virtualization is fixed — double-click fix-docker.cmd (it runs 'wsl --install'; details above and in the README).";
  // Docker Desktop can't start without hardware virtualization + WSL — diagnose instead of waiting.
  if (WIN && doctor("-CheckOnly") !== 0) return VIRT_FIX;
  log("Starting Docker… (first launch can take a minute; accept any Docker Desktop prompts)");
  launchDaemon();
  for (let i = 0; i < 90; i++) {
    await sleep(2000);
    if (daemonUp()) return null;
    // Docker logged "Virtualization support not detected"? The engine will never come up.
    if (WIN && i % 5 === 4 && doctor("-LogCheck", "ignore") !== 0) {
      doctor("-CheckOnly", "inherit", "-DockerFailed");
      return VIRT_FIX;
    }
  }
  if (WIN && doctor("-CheckOnly", "inherit", "-DockerFailed") !== 0) return VIRT_FIX;
  return WIN
    ? "Docker did not start. Open Docker Desktop and wait for 'Engine running'. If it says 'Virtualization support not detected', run fix-docker.cmd."
    : "Docker did not start. Open Docker Desktop, wait until it says 'Engine running', then try again.";
}

// ---------------------------------------------------------------------------
// Port: use POSTGRES_PORT unless something that isn't our container holds it.
// ---------------------------------------------------------------------------
function ourPublishedPort() {
  const out = docker(["port", CONTAINER, "5432/tcp"]).stdout || "";
  const m = out.match(/:(\d+)\s*$/m);
  return m ? Number(m[1]) : null;
}

async function resolveDbPort(env, log) {
  const want = Number(env.POSTGRES_PORT);
  if (ourPublishedPort() === want || (await isFree(want))) return want;
  const holder = whoHas(want);
  const port = await findFree(want + 1);
  setLocal("POSTGRES_PORT", port);
  log(`Port ${want} is already used by ${holder}. Using ${port} instead (saved to .env.local).`);
  return port;
}

// ---------------------------------------------------------------------------
// Major-version upgrades: Postgres can't open an older major's data files, so
// dump the old volume with its own version, then restore into the new one.
// ---------------------------------------------------------------------------
function oldVolumes(target) {
  const names = (docker(["volume", "ls", "--format", "{{.Name}}"]).stdout || "").split("\n");
  return names.filter((n) => /^hackalem-pgdata(-\d+)?$/.test(n) && n !== target);
}

function pgVersionIn(volume, image) {
  // Legacy volumes hold the data dir at their root; PG18+ style volumes hold <major>/docker/.
  const probe = docker([
    "run", "--rm", "-v", `${volume}:/v`, "--entrypoint", "sh", image, "-c",
    "cat /v/PG_VERSION 2>/dev/null && echo legacy || (cat /v/*/docker/PG_VERSION 2>/dev/null && echo modern)",
  ]);
  const [ver, layout] = (probe.stdout || "").trim().split(/\s+/);
  return ver ? { ver, layout } : null;
}

async function dumpOldVolume(env, log) {
  const target = `hackalem-pgdata-${env.POSTGRES_VERSION}`;
  if (docker(["volume", "inspect", target], { stdio: "ignore" }).status === 0) return null;
  const image = `postgres:${env.POSTGRES_VERSION}`;
  for (const vol of oldVolumes(target)) {
    const found = pgVersionIn(vol, image);
    if (!found || found.ver === String(env.POSTGRES_VERSION)) continue;
    log(`Upgrading your database from PostgreSQL ${found.ver} → ${env.POSTGRES_VERSION} (your data is kept)…`);
    docker(["rm", "-f", CONTAINER]);
    const tmp = `${CONTAINER}-upgrade`;
    docker(["rm", "-f", tmp]);
    const mount = found.layout === "legacy" ? "/var/lib/postgresql/data" : "/var/lib/postgresql";
    const run = docker([
      "run", "-d", "--name", tmp, "-v", `${vol}:${mount}`,
      "-e", `POSTGRES_USER=${env.POSTGRES_USER}`, "-e", `POSTGRES_PASSWORD=${env.POSTGRES_PASSWORD}`,
      "-e", `POSTGRES_DB=${env.POSTGRES_DB}`, `postgres:${found.ver}`,
    ]);
    if (run.status !== 0) throw new Error(`Could not start PostgreSQL ${found.ver} to read old data:\n${run.stderr}`);
    try {
      let ready = false;
      for (let i = 0; i < 60 && !ready; i++) {
        ready = docker(["exec", tmp, "pg_isready", "-U", env.POSTGRES_USER, "-d", env.POSTGRES_DB]).status === 0;
        if (!ready) await sleep(1000);
      }
      if (!ready) throw new Error(`PostgreSQL ${found.ver} did not start on the old data.`);
      const dump = docker(["exec", tmp, "pg_dump", "-U", env.POSTGRES_USER, "--no-owner", "--no-privileges", "--clean", "--if-exists", env.POSTGRES_DB]);
      if (dump.status !== 0) throw new Error(`Could not export old data:\n${dump.stderr}`);
      fs.mkdirSync(path.join(ROOT, "logs"), { recursive: true });
      const backup = path.join(ROOT, "logs", `backup-pg${found.ver}.sql`);
      fs.writeFileSync(backup, dump.stdout);
      return { sql: dump.stdout, from: found.ver, volume: vol, backup };
    } finally {
      docker(["rm", "-f", tmp]);
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// Bring the database up: Docker → port → upgrade → compose up → verify.
// ---------------------------------------------------------------------------
function composeUp() {
  const res = docker(["compose", "up", "-d", "--wait", "db"]);
  return { ok: res.status === 0, output: `${res.stdout}${res.stderr}` };
}

async function dbUp(log = console.log) {
  const env = loadEnv();
  const err = await ensureDocker(log);
  if (err) throw new Error(err);

  env.POSTGRES_PORT = String(await resolveDbPort(env, log));
  composeVars = { ...env };
  const upgrade = await dumpOldVolume(env, log);

  let up = composeUp();
  if (!up.ok && /address already in use|port is already allocated|bind/i.test(up.output)) {
    // Something grabbed the port between our check and Docker's bind — move once more.
    const port = await findFree(Number(env.POSTGRES_PORT) + 1);
    log(`Port ${env.POSTGRES_PORT} was taken while starting. Using ${port} instead (saved to .env.local).`);
    setLocal("POSTGRES_PORT", port);
    env.POSTGRES_PORT = String(port);
    composeVars = { ...env };
    docker(["rm", "-f", CONTAINER]);
    up = composeUp();
  }
  if (!up.ok) throw new Error(`The database container didn't start:\n${up.output.trim().split("\n").slice(-12).join("\n")}`);

  if (upgrade) {
    const restore = docker(["exec", "-i", CONTAINER, "psql", "-q", "-v", "ON_ERROR_STOP=1", "-U", env.POSTGRES_USER, "-d", env.POSTGRES_DB], {
      input: upgrade.sql,
    });
    if (restore.status !== 0) {
      throw new Error(`Upgrade restore failed (backup saved at ${path.relative(ROOT, upgrade.backup)}):\n${restore.stderr}`);
    }
    log(`Upgraded to PostgreSQL ${env.POSTGRES_VERSION}. Old data kept in volume '${upgrade.volume}' — remove with: docker volume rm ${upgrade.volume}`);
  }

  const check = docker(["exec", CONTAINER, "psql", "-U", env.POSTGRES_USER, "-d", env.POSTGRES_DB, "-tAc", "SHOW server_version"]);
  if (check.status !== 0) throw new Error(`Connected to Docker but not to database '${env.POSTGRES_DB}':\n${check.stderr}`);
  env.SERVER_VERSION = check.stdout.trim().split(" ")[0];
  return env;
}

// Pull the newest image for our major version (e.g. 18.x) so everyone runs the latest patch.
function pullDb() {
  composeVars = { ...loadEnv() };
  const res = docker(["compose", "pull", "db"]);
  return { ok: res.status === 0, output: `${res.stdout}${res.stderr}` };
}

module.exports = { docker, ensureDocker, dbUp, pullDb, CONTAINER };
