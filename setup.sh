#!/usr/bin/env bash
# ============================================================================
#  HackAlem / QBERS — one-command setup (macOS · Linux · Git Bash on Windows)
#  Installs Homebrew / winget / apt, then Python, Node.js and Docker, starts
#  PostgreSQL in Docker with the team's database, installs the Django + React
#  dependencies, and launches the app at http://localhost:5173.
#
#  Usage:  ./setup.sh          (safe to re-run any time)
#  All settings (DB name, user, password, port, API keys) come from .env.
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
ask()  { [[ -t 0 ]] && read -r -p "  ↳ $1 " REPLY || REPLY=""; }

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

[[ -f .env ]] || die ".env is missing. It's committed to the repo — run 'git pull' (or re-clone) and try again."
set -a; source .env; set +a   # POSTGRES_* etc. — the single source of truth

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

# ---------------------------------------------------------------------------
# 2. Package manager + Python, Node.js, Docker
# ---------------------------------------------------------------------------
DOCKER=(docker)

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

  step "Python, Node.js, Docker Desktop"
  has python3 || brew install python
  has node    || brew install node
  if ! has docker; then
    warn "Docker not found — installing Docker Desktop"
    brew install --cask docker
  fi
  start_docker() { open -a Docker; }

elif [[ $OS == linux ]]; then
  step "apt packages"
  has apt-get || die "Only apt-based Linux is automated. Install python3, nodejs and docker manually, then re-run."
  sudo apt-get update -y
  sudo apt-get install -y python3 python3-venv python3-pip curl
  if ! has node || [[ $(node -v | tr -d v | cut -d. -f1) -lt 20 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
  if ! has docker; then
    warn "Docker not found — installing Docker Engine"
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER" || true
  fi
  start_docker() { sudo systemctl start docker || sudo service docker start; }

else # windows (Git Bash)
  step "winget"
  has winget || die "winget not found. Install 'App Installer' from the Microsoft Store, then re-run."
  WG=(winget install --silent --accept-package-agreements --accept-source-agreements -e --id)
  has python || has py || "${WG[@]}" Python.Python.3.12
  has node   || "${WG[@]}" OpenJS.NodeJS.LTS
  has docker || [[ -x "/c/Program Files/Docker/Docker/resources/bin/docker.exe" ]] || "${WG[@]}" Docker.DockerDesktop
  export PATH="/c/Program Files/Docker/Docker/resources/bin:/c/Program Files/nodejs:$PATH"
  start_docker() { "/c/Program Files/Docker/Docker/Docker Desktop.exe" >/dev/null 2>&1 & }
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
# 3. Docker engine + login
# ---------------------------------------------------------------------------
step "Docker"
has docker || die "Docker not found after install. Open a new terminal and re-run ./setup.sh."
docker_up() {
  if docker info >/dev/null 2>&1; then DOCKER=(docker); return 0; fi
  # Linux right after install: the docker group only applies after re-login.
  if [[ $OS == linux ]] && sudo docker info >/dev/null 2>&1; then DOCKER=(sudo docker); return 0; fi
  return 1
}
if ! docker_up; then
  warn "Starting Docker… on first launch, accept the Docker Desktop terms if a window opens."
  start_docker
  for _ in {1..90}; do docker_up && break; sleep 2; done
fi
docker_up || die "Docker didn't start. Open Docker Desktop, wait for 'Engine running', then re-run ./setup.sh."
ok "$("${DOCKER[@]}" --version)"

ask "Log in to Docker Hub? Optional; avoids anonymous download limits. [y/N]"
if [[ $REPLY =~ ^[Yy] ]]; then
  # docker login asks for your username + password/token itself; nothing is stored by this script.
  "${DOCKER[@]}" login || warn "Docker login failed — continuing without it."
fi

# ---------------------------------------------------------------------------
# 4. PostgreSQL in Docker
# ---------------------------------------------------------------------------
step "PostgreSQL $POSTGRES_VERSION (Docker) → 127.0.0.1:$POSTGRES_PORT"
"${DOCKER[@]}" compose up -d --wait db || die "Database container failed — run 'docker compose logs db' to see why."
"${DOCKER[@]}" compose exec -T db psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT 1" >/dev/null \
  || die "Could not connect to database '$POSTGRES_DB' as '$POSTGRES_USER'."
ok "database '$POSTGRES_DB' ready (user '$POSTGRES_USER')"

# ---------------------------------------------------------------------------
# 5. Python / Django
# ---------------------------------------------------------------------------
step "Django backend"
[[ -d .venv ]] || $PY -m venv .venv
if [[ -f .venv/bin/activate ]]; then source .venv/bin/activate; else source .venv/Scripts/activate; fi
python -m pip install --quiet --upgrade pip
python -m pip install --quiet -r backend/requirements.txt
python backend/manage.py migrate --noinput
ok "Django $(python -c 'import django; print(django.get_version())') connected + migrated"

# ---------------------------------------------------------------------------
# 6. React frontend
# ---------------------------------------------------------------------------
step "React frontend"
(cd frontend && npm install --no-fund --no-audit --loglevel=error)
ok "npm packages installed"

# ---------------------------------------------------------------------------
# 7. Launch
# ---------------------------------------------------------------------------
printf "\n${G}✔ Setup complete.${N} Next time, just run: ${C}npm start${N}\n"
exec node "$ROOT/scripts/start.js"
