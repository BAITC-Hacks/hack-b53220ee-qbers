// Minimal .env reader so the Node scripts use the same values as Django/Vite/Compose.
const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..", "..");

function loadEnv() {
  const file = path.join(ROOT, ".env");
  const vars = {};
  if (!fs.existsSync(file)) return vars;
  for (const line of fs.readFileSync(file, "utf8").split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
    if (!m) continue;
    let value = m[2];
    const quoted = value.match(/^(['"])(.*)\1$/);
    value = quoted ? quoted[2] : value.replace(/\s+#.*$/, "");
    vars[m[1]] = value;
  }
  // Real environment variables win, same as Django, Vite and Docker Compose.
  for (const key of Object.keys(vars)) if (process.env[key] !== undefined) vars[key] = process.env[key];
  return vars;
}

module.exports = { ROOT, loadEnv };
