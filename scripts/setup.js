#!/usr/bin/env node
// `npm run setup` / `pnpm run setup` — hands off to the platform's installer.
const { spawnSync } = require("node:child_process");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..");
const [cmd, args] =
  process.platform === "win32"
    ? ["cmd.exe", ["/c", path.join(ROOT, "setup.cmd")]]
    : ["bash", [path.join(ROOT, "setup.sh")]];
process.exit(spawnSync(cmd, args, { cwd: ROOT, stdio: "inherit" }).status ?? 1);
