#!/usr/bin/env node
// Team database helpers (all settings come from .env / .env.local):
//   npm run db:up         start the database (handles busy ports + version upgrades)
//   npm run db:snapshot   save your current data to db/init/01-snapshot.sql (commit it to share)
//   npm run db:reset      wipe your local database and reload it from the snapshot
//   npm run db:shell      open psql inside the container
//   node scripts/db.js pull   download the newest image for our Postgres version
const fs = require("node:fs");
const path = require("node:path");
const { ROOT } = require("./lib/env");
const { docker, dbUp, pullDb, CONTAINER } = require("./lib/docker");

const SNAPSHOT = path.join(ROOT, "db", "init", "01-snapshot.sql");
const note = (m) => console.log(`NOTE: ${m}`);
const fail = (msg) => (console.error(`\n  ✖ ${msg}\n`), process.exit(1));

const commands = {
  async up() {
    const env = await dbUp(note);
    console.log(`READY PostgreSQL ${env.SERVER_VERSION} on 127.0.0.1:${env.POSTGRES_PORT}`);
  },
  async pull() {
    const res = pullDb();
    if (!res.ok) fail(`Could not download the PostgreSQL image:\n${res.output}`);
    console.log(res.output.trim());
  },
  async snapshot() {
    const env = await dbUp(note);
    const res = docker(["exec", CONTAINER, "pg_dump", "-U", env.POSTGRES_USER, "--no-owner", "--no-privileges", "--clean", "--if-exists", env.POSTGRES_DB]);
    if (res.status !== 0) fail(`pg_dump failed:\n${res.stderr}`);
    fs.writeFileSync(SNAPSHOT, res.stdout);
    console.log(`  ✔ Saved ${path.relative(ROOT, SNAPSHOT)} — commit it so teammates get the same data.`);
  },
  async reset() {
    if (docker(["compose", "down", "-v"], { stdio: "inherit" }).status !== 0) fail("docker compose down failed.");
    const env = await dbUp(note);
    console.log(`  ✔ Database recreated from the snapshot (PostgreSQL ${env.SERVER_VERSION}). Run \`npm start\` next.`);
  },
  async shell() {
    const env = await dbUp(note);
    process.exit(docker(["exec", "-it", CONTAINER, "psql", "-U", env.POSTGRES_USER, env.POSTGRES_DB], { stdio: "inherit" }).status ?? 1);
  },
};

(async () => {
  const cmd = commands[process.argv[2]];
  if (!cmd) fail(`Usage: node scripts/db.js <${Object.keys(commands).join("|")}>`);
  try {
    await cmd();
  } catch (e) {
    fail(e.message);
  }
})();
