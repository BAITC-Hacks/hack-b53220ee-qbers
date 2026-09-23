#!/usr/bin/env node
// Cross-platform launcher behind `npm start` / `pnpm start` (also used by run.sh).
// Starts the PostgreSQL Docker container, runs migrations, starts Django (:8000 or
// the next free port) and React/Vite (:5173), then opens the browser. Ctrl+C stops
// both servers; the database container keeps running in the background.
const { spawn, spawnSync, execSync } = require("node:child_process");
const fs = require("node:fs");
const net = require("node:net");
const path = require("node:path");
const { ROOT, loadEnv } = require("./lib/env");
const { ensureDocker, composeUpDb } = require("./lib/docker");

const WIN = process.platform === "win32";
const PY = path.join(ROOT, ".venv", WIN ? "Scripts/python.exe" : "bin/python");
const MANAGE = path.join(ROOT, "backend", "manage.py");
const VITE = path.join(ROOT, "frontend", "node_modules", "vite", "bin", "vite.js");

const c = (code) => (s) => (process.stdout.isTTY ? `\x1b[38;5;${code}m${s}\x1b[0m` : s);
const cyan = c(51), green = c(84), red = c(203), yellow = c(221);

function fail(msg) {
  console.error(`\n  ${red("✖")} ${msg}\n`);
  process.exit(1);
}

function portOpen(port) {
  return new Promise((resolve) => {
    const sock = net.connect({ port, host: "127.0.0.1" });
    sock.once("connect", () => (sock.destroy(), resolve(true)));
    sock.once("error", () => resolve(false));
  });
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function ensurePostgres() {
  const env = loadEnv();
  const err = await ensureDocker((m) => console.log(yellow(m)));
  if (err) fail(err);
  console.log(`  Starting PostgreSQL container on 127.0.0.1:${env.POSTGRES_PORT}…`);
  if (!composeUpDb()) fail("Could not start the PostgreSQL container — run `docker compose logs db` to see why.");
  if (!(await portOpen(Number(env.POSTGRES_PORT)))) fail(`Nothing is listening on port ${env.POSTGRES_PORT}.`);
}

const children = [];
function stopAll() {
  for (const child of children) {
    if (child.exitCode !== null) continue;
    try {
      // Django's autoreloader spawns a grandchild, so kill the whole tree.
      if (WIN) execSync(`taskkill /pid ${child.pid} /T /F`, { stdio: "ignore" });
      else if (child.spawnargs.includes("runserver")) process.kill(-child.pid, "SIGTERM");
      else child.kill("SIGTERM");
    } catch {}
  }
}
process.on("SIGINT", () => (stopAll(), process.exit(0)));
process.on("SIGTERM", () => (stopAll(), process.exit(0)));
process.on("exit", stopAll);

async function main() {
  const setupCmd = WIN ? "setup.cmd" : "./setup.sh";
  if (!fs.existsSync(PY) || !fs.existsSync(VITE) || !fs.existsSync(path.join(ROOT, ".env"))) {
    fail(`Not set up yet — run ${cyan(setupCmd)} first.`);
  }

  await ensurePostgres();

  const migrate = spawnSync(PY, [MANAGE, "migrate", "--noinput"], { cwd: ROOT, encoding: "utf8" });
  if (migrate.status !== 0) fail(`Database migration failed:\n${migrate.stderr || migrate.stdout}`);

  let port = 8000;
  while (await portOpen(port)) port++;

  fs.mkdirSync(path.join(ROOT, "logs"), { recursive: true });
  const log = fs.openSync(path.join(ROOT, "logs", "django.log"), "w");
  const django = spawn(PY, [MANAGE, "runserver", `127.0.0.1:${port}`], {
    cwd: ROOT,
    stdio: ["ignore", log, log],
    detached: !WIN,
  });
  children.push(django);

  let up = false;
  for (let i = 0; i < 60 && !up; i++) {
    if (django.exitCode !== null) break;
    up = await fetch(`http://127.0.0.1:${port}/api/health/`).then((r) => r.ok, () => false);
    if (!up) await sleep(500);
  }
  if (!up) {
    const tail = fs.readFileSync(path.join(ROOT, "logs", "django.log"), "utf8").split("\n").slice(-20).join("\n");
    fail(`Django failed to start — see logs/django.log\n${tail}`);
  }

  console.log(`\n  ${green("●")} Django API   ${cyan(`http://127.0.0.1:${port}/api/health/`)}  (logs/django.log)`);
  console.log(`  ${green("●")} Web app      ${cyan("http://localhost:5173")}`);
  console.log("    Press Ctrl+C to stop both servers.\n");

  const vite = spawn(process.execPath, [VITE, "--open"], {
    cwd: path.join(ROOT, "frontend"),
    stdio: "inherit",
    env: { ...process.env, DJANGO_PORT: String(port) },
  });
  children.push(vite);
  vite.on("exit", (code) => process.exit(code ?? 0));
  django.on("exit", (code) => {
    if (vite.exitCode === null) fail(`Django stopped unexpectedly (exit ${code}) — see logs/django.log`);
  });
}

main();
