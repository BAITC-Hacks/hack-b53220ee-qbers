// Reads the team .env plus your personal, gitignored .env.local (which wins),
// so the Node scripts see the same values as Django, Vite and Docker Compose.
const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..", "..");
const LOCAL = path.join(ROOT, ".env.local");

function parse(file) {
  const vars = {};
  if (!fs.existsSync(file)) return vars;
  for (const line of fs.readFileSync(file, "utf8").split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
    if (!m) continue;
    const quoted = m[2].match(/^(['"])(.*)\1$/);
    vars[m[1]] = quoted ? quoted[2] : m[2].replace(/\s+#.*$/, "");
  }
  return vars;
}

function loadEnv() {
  const vars = { ...parse(path.join(ROOT, ".env")), ...parse(LOCAL) };
  // Real environment variables win, same as Django, Vite and Docker Compose.
  for (const key of Object.keys(vars)) if (process.env[key] !== undefined) vars[key] = process.env[key];
  return vars;
}

// Save a personal override (e.g. a free port) to .env.local — never touches the team .env.
function setLocal(key, value) {
  let text = fs.existsSync(LOCAL) ? fs.readFileSync(LOCAL, "utf8") : "# Personal overrides for this computer only (gitignored).\n";
  const line = `${key}=${value}`;
  const re = new RegExp(`^${key}=.*$`, "m");
  text = re.test(text) ? text.replace(re, line) : `${text.replace(/\n?$/, "\n")}${line}\n`;
  fs.writeFileSync(LOCAL, text);
}

module.exports = { ROOT, loadEnv, setLocal };
