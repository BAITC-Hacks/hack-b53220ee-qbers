#!/usr/bin/env node
// Team database helpers (all settings come from .env):
//   npm run db:snapshot   save your current data to db/init/01-snapshot.sql (commit it to share)
//   npm run db:reset      wipe your local database and reload it from the snapshot
//   npm run db:shell      open psql inside the container
const fs = require("node:fs");
const path = require("node:path");
const { ROOT, loadEnv } = require("./lib/env");
const { docker, ensureDocker, composeUpDb } = require("./lib/docker");

const env = loadEnv();
const SNAPSHOT = path.join(ROOT, "db", "init", "01-snapshot.sql");
const fail = (msg) => (console.error(`\n  ✖ ${msg}\n`), process.exit(1));

const commands = {
  snapshot() {
    const res = docker(
      ["compose", "exec", "-T", "db", "pg_dump", "-U", env.POSTGRES_USER, "--no-owner", "--no-privileges", "--clean", "--if-exists", env.POSTGRES_DB],
      { maxBuffer: 512 * 1024 * 1024 }
    );
    if (res.status !== 0) fail(`pg_dump failed:\n${res.stderr}`);
    fs.writeFileSync(SNAPSHOT, res.stdout);
    console.log(`  ✔ Saved ${path.relative(ROOT, SNAPSHOT)} — commit it so teammates get the same data.`);
  },
  reset() {
    if (docker(["compose", "down", "-v"], { stdio: "inherit" }).status !== 0) fail("docker compose down failed.");
    if (!composeUpDb()) fail("Could not start the database container.");
    console.log("  ✔ Database recreated from the snapshot. Run `npm start` next.");
  },
  shell() {
    process.exit(docker(["compose", "exec", "db", "psql", "-U", env.POSTGRES_USER, env.POSTGRES_DB], { stdio: "inherit" }).status ?? 1);
  },
};

(async () => {
  const cmd = commands[process.argv[2]];
  if (!cmd) fail(`Usage: node scripts/db.js <${Object.keys(commands).join("|")}>`);
  const err = await ensureDocker();
  if (err) fail(err);
  if (process.argv[2] !== "reset" && !composeUpDb()) fail("Could not start the database container.");
  cmd();
})();
