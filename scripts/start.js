#!/usr/bin/env node
// Cross-platform launcher behind `npm start` / `pnpm start` (also used by run.sh).
// Starts the PostgreSQL Docker container, runs migrations, starts Django and
// React/Vite, then opens the browser. Every port falls back to the next free one
// if something else already uses it (database :55432, Django :8000, web :5173).
// Ctrl+C stops both servers; the database container keeps running in Docker.
const { spawn, spawnSync, execSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");
const { ROOT } = require("./lib/env");
const { dbUp } = require("./lib/docker");
const { findFree, whoHas } = require("./lib/ports");

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

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function ensurePostgres() {
  console.log("  Starting PostgreSQL in Docker…");
  try {
    const env = await dbUp((m) => console.log(`  ${yellow("⚠")} ${m}`));
    console.log(`  ${green("✔")} PostgreSQL ${env.SERVER_VERSION} on 127.0.0.1:${env.POSTGRES_PORT}`);
    return env;
  } catch (e) {
    fail(e.message);
  }
}

async function pickPort(preferred, name) {
  const port = await findFree(preferred);
  if (port !== preferred) console.log(`  ${yellow("⚠")} Port ${preferred} is used by ${whoHas(preferred)} — ${name} will use ${port}.`);
  return port;
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

  const env = await ensurePostgres();
  const dbEnv = { ...process.env, POSTGRES_PORT: env.POSTGRES_PORT };

  const migrate = spawnSync(PY, [MANAGE, "migrate", "--noinput"], { cwd: ROOT, encoding: "utf8", env: dbEnv });
  if (migrate.status !== 0) fail(`Database migration failed:\n${migrate.stderr || migrate.stdout}`);

  const port = await pickPort(8000, "Django");
  const webPort = await pickPort(5173, "the web app");

  fs.mkdirSync(path.join(ROOT, "logs"), { recursive: true });
  const log = fs.openSync(path.join(ROOT, "logs", "django.log"), "w");
  const django = spawn(PY, [MANAGE, "runserver", `127.0.0.1:${port}`], {
    cwd: ROOT,
    stdio: ["ignore", log, log],
    env: dbEnv,
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
  console.log(`  ${green("●")} Web app      ${cyan(`http://localhost:${webPort}`)}`);
  if (webPort !== 5173) console.log(`    ${yellow("⚠")} Sign in with Google only works on port 5173 — free it up to test sign-in.`);
  console.log("    Press Ctrl+C to stop both servers.\n");

  const vite = spawn(process.execPath, [VITE, "--open", "--port", String(webPort), "--strictPort"], {
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
