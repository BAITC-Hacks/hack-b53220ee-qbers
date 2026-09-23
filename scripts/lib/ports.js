// Port helpers: a port counts as busy if anything answers on it OR we can't bind it.
const net = require("node:net");
const { spawnSync } = require("node:child_process");

// Check IPv4 and IPv6 loopback: "localhost" often resolves to ::1 (e.g. Vite),
// so a server there is invisible to a 127.0.0.1-only check.
const HOSTS = ["127.0.0.1", "::1"];

function answers(port, host) {
  return new Promise((resolve) => {
    const sock = net.connect({ port, host });
    sock.setTimeout(800, () => (sock.destroy(), resolve(false)));
    sock.once("connect", () => (sock.destroy(), resolve(true)));
    sock.once("error", () => resolve(false));
  });
}

function bindable(port, host) {
  return new Promise((resolve) => {
    const srv = net.createServer();
    // No IPv6 on this machine counts as "free" — nothing can be listening there.
    srv.once("error", (e) => resolve(["EADDRNOTAVAIL", "EAFNOSUPPORT"].includes(e.code)));
    srv.listen({ port, host, ipv6Only: host === "::1" }, () => srv.close(() => resolve(true)));
  });
}

async function isFree(port) {
  for (const host of HOSTS) {
    if ((await answers(port, host)) || !(await bindable(port, host))) return false;
  }
  return true;
}

async function findFree(start, tries = 50) {
  for (let p = start; p < start + tries; p++) if (await isFree(p)) return p;
  throw new Error(`No free port found between ${start} and ${start + tries - 1}.`);
}

// Best-effort description of what is holding a port, for friendlier messages.
function whoHas(port) {
  const dockerName = spawnSync("docker", ["ps", "--filter", `publish=${port}`, "--format", "{{.Names}} ({{.Image}})"], {
    encoding: "utf8",
  }).stdout?.trim();
  if (dockerName) return `Docker container ${dockerName.split("\n")[0]}`;
  if (process.platform !== "win32") {
    const out = spawnSync("lsof", ["-nP", `-iTCP:${port}`, "-sTCP:LISTEN"], { encoding: "utf8" }).stdout || "";
    const row = out.split("\n")[1]?.trim().split(/\s+/);
    if (row?.length) return `${row[0]} (PID ${row[1]})`;
  } else {
    const out = spawnSync("netstat", ["-ano", "-p", "TCP"], { encoding: "utf8" }).stdout || "";
    const row = out.split("\n").find((l) => l.includes(`:${port} `) && /LISTENING/.test(l));
    if (row) return `PID ${row.trim().split(/\s+/).pop()}`;
  }
  return "another program";
}

module.exports = { isFree, findFree, whoHas };
