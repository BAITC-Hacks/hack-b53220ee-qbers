#!/usr/bin/env node
// Runs a Django management command with the project's virtualenv on any OS:
//   node scripts/manage.js import_transport
const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..");
const py = path.join(ROOT, ".venv", process.platform === "win32" ? "Scripts/python.exe" : "bin/python");
if (!fs.existsSync(py)) {
  console.error(`\n  ✖ Not set up yet — run ${process.platform === "win32" ? "setup.cmd" : "./setup.sh"} first.\n`);
  process.exit(1);
}
const res = spawnSync(py, [path.join(ROOT, "backend", "manage.py"), ...process.argv.slice(2)], { cwd: ROOT, stdio: "inherit" });
process.exit(res.status ?? 1);
