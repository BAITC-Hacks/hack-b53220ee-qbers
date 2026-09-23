#!/usr/bin/env bash
# ============================================================================
#  HackAlem / QBERS — one-command setup
#  Installs Homebrew (macOS) or uses winget (Windows / Git Bash) or apt (Linux),
#  then Python, Node.js, PostgreSQL, the Django + React dependencies, creates
#  the database, and launches the app at http://localhost:5173.
#
#  Usage:  ./setup.sh          (safe to re-run any time)
# ============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

C="\033[38;5;51m"; V="\033[38;5;141m"; G="\033[38;5;84m"; Y="\033[38;5;221m"; R="\033[38;5;203m"; N="\033[0m"
step() { printf "\n${V}▸${N} ${C}%s${N}\n" "$*"; }
ok()   { printf "  ${G}✔${N} %s\n" "$*"; }
warn() { printf "  ${Y}⚠${N} %s\n" "$*"; }
die()  { printf "\n  ${R}✖ %s${N}\n\n" "$*"; exit 1; }
has()  { command -v "$1" >/dev/null 2>&1; }

printf "${C}"
cat <<'BANNER'

   ██████╗ ██████╗ ███████╗██████╗ ███████╗
  ██╔═══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝
  ██║   ██║██████╔╝█████╗  ██████╔╝███████╗
  ██║▄▄ ██║██╔══██╗██╔══╝  ██╔══██╗╚════██║
  ╚██████╔╝██████╔╝███████╗██║  ██║███████║
   ╚══▀▀═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝
          HackAlem · local environment setup
BANNER
printf "${N}"

# ---------------------------------------------------------------------------
# 1. Detect platform
# ---------------------------------------------------------------------------
case "$(uname -s)" in
  Darwin*)               OS=mac ;;
  Linux*)                OS=linux ;;
  MINGW*|MSYS*|CYGWIN*)  OS=windows ;;
  *)                     die "Unsupported OS: $(uname -s)" ;;
esac
step "Detected platform: $OS"

PG_MAJOR=16
DB_NAME=hackalem; DB_USER=hackalem; DB_PASS=hackalem

# ---------------------------------------------------------------------------
# 2. Package manager + system software
# ---------------------------------------------------------------------------
if [[ $OS == mac ]]; then
  step "Homebrew"
  if ! has brew; then
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do [[ -x $p ]] && eval "$($p shellenv)"; done
  fi
  if ! has brew; then
    warn "Homebrew not found — installing (you may be asked for your Mac password)"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do [[ -x $p ]] && eval "$($p shellenv)"; done
  fi
  ok "brew $(brew --version | head -1 | awk '{print $2}')"

  step "Python, Node.js, PostgreSQL"
  has python3 || brew install python
  has node    || brew install node
  brew list --versions "postgresql@$PG_MAJOR" >/dev/null 2>&1 || brew install "postgresql@$PG_MAJOR"
  export PATH="$(brew --prefix "postgresql@$PG_MAJOR")/bin:$PATH"
  brew services start "postgresql@$PG_MAJOR" >/dev/null 2>&1 || true
  PSQL_SUPER=(psql -d postgres)

elif [[ $OS == linux ]]; then
  step "apt packages"
  has apt-get || die "Only apt-based Linux is automated. Install python3, nodejs, npm and postgresql manually, then re-run."
  sudo apt-get update -y
  sudo apt-get install -y python3 python3-venv python3-pip postgresql postgresql-contrib curl
  if ! has node || [[ $(node -v | tr -d v | cut -d. -f1) -lt 20 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
  sudo service postgresql start || sudo systemctl start postgresql || true
  PSQL_SUPER=(sudo -u postgres psql -d postgres)

else # windows (Git Bash)
  step "winget"
  has winget || die "winget not found. Install 'App Installer' from the Microsoft Store, then re-run this script in Git Bash."
  WG=(winget install --silent --accept-package-agreements --accept-source-agreements -e --id)
  has python || has py || "${WG[@]}" Python.Python.3.12
  has node   || "${WG[@]}" OpenJS.NodeJS.LTS
  PG_BIN="/c/Program Files/PostgreSQL/$PG_MAJOR/bin"
  if [[ ! -x "$PG_BIN/psql.exe" ]]; then
    "${WG[@]}" "PostgreSQL.PostgreSQL.$PG_MAJOR" --override "--mode unattended --superpassword postgres --serverport 5432"
  fi
  export PATH="$PG_BIN:/c/Program Files/nodejs:$PATH"
  export PGPASSWORD=postgres
  PSQL_SUPER=(psql -U postgres -h localhost -d postgres)
  warn "If a tool is still 'not found', close and reopen Git Bash so PATH refreshes, then re-run."
fi

# Resolve python executable
if has python3 && python3 -c "import sys" >/dev/null 2>&1; then PY=python3
elif has python; then PY=python
elif has py; then PY="py -3"
else die "Python not found after install."; fi
ok "$($PY --version)"
has node || die "Node.js not found after install."
ok "node $(node -v) · npm $(npm -v)"

# ---------------------------------------------------------------------------
# 3. PostgreSQL database + role
# ---------------------------------------------------------------------------
step "PostgreSQL database"
for _ in {1..30}; do pg_isready -h localhost -q && break; sleep 1; done
pg_isready -h localhost -q || die "PostgreSQL is not accepting connections on localhost:5432."
ok "$(psql --version)"

if [[ -z $("${PSQL_SUPER[@]}" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'") ]]; then
  "${PSQL_SUPER[@]}" -qc "CREATE ROLE $DB_USER LOGIN PASSWORD '$DB_PASS' CREATEDB;"
  ok "created role $DB_USER"
fi
if [[ -z $("${PSQL_SUPER[@]}" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'") ]]; then
  "${PSQL_SUPER[@]}" -qc "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
  ok "created database $DB_NAME"
fi
ok "database '$DB_NAME' ready"

# ---------------------------------------------------------------------------
# 4. .env
# ---------------------------------------------------------------------------
step "Environment (.env)"
set_env() { # set_env KEY VALUE — replace the KEY= line in .env
  $PY - "$1" "$2" <<'PY'
import re, sys, pathlib
key, val = sys.argv[1], sys.argv[2]
p = pathlib.Path(".env"); s = p.read_text()
s = re.sub(rf"^{key}=.*$", lambda _: f"{key}={val}", s, count=1, flags=re.M)
p.write_text(s)
PY
}
get_env() { grep -E "^$1=" .env | head -1 | cut -d= -f2-; }

if [[ ! -f .env ]]; then
  cp .env.example .env
  ok "created .env from .env.example"
fi
if [[ -z $(get_env DJANGO_SECRET_KEY) ]]; then
  set_env DJANGO_SECRET_KEY "$($PY -c 'import secrets; print(secrets.token_urlsafe(50))')"
  ok "generated DJANGO_SECRET_KEY"
fi
for key in GOOGLE_API_KEY GOOGLE_OAUTH_CLIENT_ID GOOGLE_OAUTH_CLIENT_SECRET; do
  if [[ -z $(get_env $key) ]]; then
    if [[ -t 0 ]]; then
      read -r -p "  ↳ Paste $key (Enter to skip): " val
      [[ -n $val ]] && set_env "$key" "$val"
    else
      warn "$key is empty — add it to .env for Google features"
    fi
  fi
done
ok ".env ready"

# ---------------------------------------------------------------------------
# 5. Python / Django
# ---------------------------------------------------------------------------
step "Django backend"
[[ -d .venv ]] || $PY -m venv .venv
if [[ -f .venv/bin/activate ]]; then source .venv/bin/activate; else source .venv/Scripts/activate; fi
python -m pip install --quiet --upgrade pip
python -m pip install --quiet -r backend/requirements.txt
python backend/manage.py migrate --noinput
ok "Django $(python -c 'import django; print(django.get_version())') migrated"

# ---------------------------------------------------------------------------
# 6. React frontend
# ---------------------------------------------------------------------------
step "React frontend"
(cd frontend && npm install --no-fund --no-audit --loglevel=error)
ok "npm packages installed"

# ---------------------------------------------------------------------------
# 7. Launch
# ---------------------------------------------------------------------------
printf "\n${G}✔ Setup complete.${N} Launching the app…\n"
exec "$ROOT/run.sh"
