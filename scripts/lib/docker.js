// Docker helpers shared by start.js and db.js.
const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const { ROOT } = require("./env");

const WIN = process.platform === "win32";
const MAC = process.platform === "darwin";
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// On Linux, a fresh install may need sudo until the user re-logs into the docker group.
let prefix = [];
function docker(args, opts = {}) {
  const [cmd, ...rest] = [...prefix, "docker", ...args];
  return spawnSync(cmd, rest, { cwd: ROOT, encoding: "utf8", ...opts });
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

async function ensureDocker(log = console.log) {
  if (spawnSync("docker", ["--version"], { stdio: "ignore", shell: WIN }).status !== 0) {
    return `Docker is not installed — run ${WIN ? "setup.cmd" : "./setup.sh"} first.`;
  }
  if (daemonUp()) return null;
  log("  Starting Docker… (first launch can take a minute; accept any Docker Desktop prompts)");
  launchDaemon();
  for (let i = 0; i < 90; i++) {
    await sleep(2000);
    if (daemonUp()) return null;
  }
  return "Docker did not start. Open Docker Desktop, wait until it says 'Engine running', then try again.";
}

// Start the Postgres container and wait until its healthcheck passes.
function composeUpDb() {
  return docker(["compose", "up", "-d", "--wait", "db"], { stdio: "inherit" }).status === 0;
}

module.exports = { docker, ensureDocker, composeUpDb };
