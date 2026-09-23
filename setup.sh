#!/usr/bin/env bash
# ============================================================================
#  HackAlem / QBERS — one-command setup (macOS · Linux · Git Bash on Windows)
#  Installs Homebrew / winget / apt, then Python, Node.js and Docker, starts
#  PostgreSQL 18 in Docker with the team's database, installs the Django +
#  React dependencies, and launches the app at http://localhost:5173.
#
#  Usage:  ./setup.sh          (safe to re-run any time — it resumes)
#  All settings (DB name, user, password, port, API keys) come from .env.
#  Full output of every step goes to logs/setup.log.
# ============================================================================
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
mkdir -p logs
LOG="$ROOT/logs/setup.log"
TASK_OUT="$ROOT/logs/.task.out"
: >"$LOG"

# Minimum versions the app needs (older → we install the latest).
MIN_PY="3.12"      # Django 6.1
MIN_NODE="22.12"   # Vite 8

# ---------------------------------------------------------------------------
# Look & feel
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then TTY=1; else TTY=0; fi
if [[ $TTY == 1 ]]; then
  C="\033[38;5;51m"; V="\033[38;5;141m"; G="\033[38;5;84m"; Y="\033[38;5;221m"
  R="\033[38;5;203m"; D="\033[38;5;244m"; B="\033[1m"; N="\033[0m"
  CLR="\r\033[K"; CUR_ON="\033[?25h"; CUR_OFF="\033[?25l"
else C=""; V=""; G=""; Y=""; R=""; D=""; B=""; N=""; CLR=""; CUR_ON=""; CUR_OFF=""; fi
SPIN=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
RAINBOW=(196 208 226 46 51 33 129 201)

has()     { command -v "$1" >/dev/null 2>&1; }
section() { printf "\n${V}▸${N} ${C}${B}%s${N}\n" "$*"; }
warn()    { printf "  ${Y}⚠${N}  %s\n" "$*"; }
info()    { printf "  ${D}•  %s${N}\n" "$*"; }
rainbow() { # rainbow "text" — each letter a different colour
  local s=$1 out="" i
  if [[ $TTY == 0 ]]; then printf "%s" "$s"; return; fi
  for ((i = 0; i < ${#s}; i++)); do out+="\033[38;5;${RAINBOW[i % ${#RAINBOW[@]}]}m${s:i:1}"; done
  printf "%b${N}" "$out"
}
congrats() { # congrats "Python 3.14.7" "extra note"
  printf "  🎉 $(rainbow "Already installed:") ${G}${B}%s${N}  ${D}%s${N}\n" "$1" "${2:-}"
  ((ALREADY += 1))
}
repeat() { local s="" k; for ((k = 0; k < $2; k++)); do s+=$1; done; printf "%s" "$s"; }
bar() { local w=22 f=$(($1 * 22 / 100)); printf "%s%s" "$(repeat █ "$f")" "$(repeat ░ $((w - f)))"; }
ver_ge() { # ver_ge 3.14.7 3.12  → true if first >= second
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" == "$2" ]]
}

# ---------------------------------------------------------------------------
# Progress + error handling
#   task <weight> "<label>" "<how to fix if it fails>" command args…
#   Runs the command with its output in logs/setup.log, while showing an
#   animated "..." preloader and the overall setup percentage.
# ---------------------------------------------------------------------------
DONE=0; ALREADY=0; INSTALLED=0

task() {
  local weight=$1 label=$2 hint=$3; shift 3
  local from=$DONE to=$((DONE + weight)) t0=$SECONDS rc=0
  printf "\n### %s\n" "$label" >>"$LOG"
  : >"$TASK_OUT"
  if [[ $TTY == 1 ]]; then
    (trap - ERR; "$@") >"$TASK_OUT" 2>&1 </dev/null &
    local pid=$! tick=0 pct dots span=$((to - from - 1))
    ((span < 0)) && span=0
    printf "${CUR_OFF}"   # hide cursor
    while kill -0 "$pid" 2>/dev/null; do
      # Creep toward the next milestone while the step runs; jumps to it when done.
      pct=$((from + span * tick / (tick + 40)))
      dots=$(repeat . $(((tick / 3) % 4)))
      printf "\r\033[K  ${C}%s${N} %s%-3s ${V}%s${N} ${B}%3d%%${N} ${D}%ds${N}" \
        "${SPIN[tick % 10]}" "$label" "$dots" "$(bar "$pct")" "$pct" $((SECONDS - t0))
      sleep 0.15; ((tick += 1))
    done
    wait "$pid" && rc=0 || rc=$?
    printf "${CUR_ON}"
  else
    printf "  …  %s\n" "$label"
    (trap - ERR; "$@") >"$TASK_OUT" 2>&1 </dev/null && rc=0 || rc=$?
  fi
  cat "$TASK_OUT" >>"$LOG"
  if ((rc != 0)); then task_failed "$label" "$hint" "$rc"; fi
  DONE=$to
  printf "${CLR}  ${G}✔${N}  %s ${D}(%ds)${N}%*s${V}%s${N} ${B}%3d%%${N}\n" \
    "$label" $((SECONDS - t0)) $((44 - ${#label})) "" "$(bar "$DONE")" "$DONE"
}

skip() { DONE=$((DONE + $1)); }   # step not needed — still advances the percentage

task_failed() {
  local label=$1 hint=$2 rc=$3
  # Optional per-step recovery hook (e.g. Windows Docker doctor); may exit itself.
  if [[ -n ${ON_FAIL:-} ]]; then local hook=$ON_FAIL; ON_FAIL=""; printf "${CLR}${CUR_ON}"; $hook; fi
  printf "${CLR}${CUR_ON}  ${R}${B}✖  %s failed${N} ${D}(exit code %s)${N}\n\n" "$label" "$rc"
  printf "  ${D}── last lines of output ─────────────────────────────${N}\n"
  tail -n 15 "$TASK_OUT" | while IFS= read -r l; do printf "  ${D}│${N} %s\n" "$l"; done
  printf "  ${D}─────────────────────────────────────────────────────${N}\n\n"
  printf "  ${Y}${B}How to fix:${N} %s\n" "$hint"
  printf "  ${D}Full log: logs/setup.log · then run ./setup.sh again — finished steps are skipped.${N}\n\n"
  exit 1
}

on_error() { # anything that fails outside a task
  printf "${CLR}${CUR_ON}\n  ${R}${B}✖  Unexpected error${N} on line %s: ${D}%s${N}\n" "$1" "$2"
  printf "  Full log: logs/setup.log — please send it to the team if this keeps happening.\n\n"
  exit 1
}
trap 'on_error $LINENO "$BASH_COMMAND"' ERR
trap 'printf "${CUR_ON}"; rm -f "$TASK_OUT"' EXIT
trap 'printf "${CLR}${CUR_ON}\n  ${Y}Setup cancelled.${N} Run ./setup.sh again any time.\n\n"; exit 130' INT

# Ask for the computer password once, up front, so background installs don't hang.
need_sudo() {
  has sudo || return 0
  sudo -n true 2>/dev/null && return 0
  info "Some installs need your computer password (asked once)."
  sudo -v || { printf "  ${R}✖  Password needed to install software.${N}\n"; exit 1; }
  (while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 50; done) 2>/dev/null &
}

# ---------------------------------------------------------------------------
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

[[ -f .env ]] || { printf "  ${R}✖  .env is missing.${N} It's committed to the repo — run 'git pull' (or re-clone), then ./setup.sh.\n"; exit 1; }
set -a; source .env; [[ -f .env.local ]] && source .env.local; set +a

case "$(uname -s)" in
  Darwin*)               OS=mac ;;
  Linux*)                OS=linux ;;
  MINGW*|MSYS*|CYGWIN*)  OS=windows ;;
  *) printf "  ${R}✖  Unsupported OS: %s${N}\n" "$(uname -s)"; exit 1 ;;
esac
info "Platform: $OS · log: logs/setup.log"

# ============================================================================
# 1. Package manager                                                  (8%)
# ============================================================================
section "Package manager"
brew_env() { for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do [[ -x $p ]] && eval "$($p shellenv)"; done; return 0; }
install_brew() {
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
apt_base() { sudo apt-get update -y && sudo apt-get install -y curl ca-certificates python3 python3-venv python3-pip; }
case $OS in
  mac)
    has brew || brew_env
    if has brew; then congrats "Homebrew $(brew --version | head -1 | awk '{print $2}')"; skip 8
    else
      need_sudo
      task 8 "Installing Homebrew" "Check your internet connection, or install Homebrew from https://brew.sh and re-run." install_brew
      brew_env; has brew || task_failed "Homebrew" "Open a new Terminal window and re-run ./setup.sh." 1
      ((INSTALLED += 1))
    fi ;;
  linux)
    has apt-get || { printf "  ${R}✖  Only apt-based Linux (Debian/Ubuntu) is automated.${N} Install python3, nodejs 22+ and docker, then re-run.\n"; exit 1; }
    need_sudo
    task 8 "Updating apt packages" "Run 'sudo apt-get update' yourself to see the error (often a broken mirror or no internet)." apt_base ;;
  windows)
    has winget || { printf "  ${R}✖  winget not found.${N} Install 'App Installer' from the Microsoft Store — or use setup.cmd from Command Prompt.\n"; exit 1; }
    congrats "winget $(winget --version 2>/dev/null)"; skip 8
    WG=(winget install --silent --accept-package-agreements --accept-source-agreements -e --id)
    export PATH="/c/Program Files/Docker/Docker/resources/bin:/c/Program Files/nodejs:$PATH" ;;
esac

# ============================================================================
# 2. Python                                                          (10%)
# ============================================================================
section "Python ≥ $MIN_PY"
find_python() {
  PY=""
  for c in python3.14 python3.13 python3.12 python3 python "py -3"; do
    if $c -c "import sys" >/dev/null 2>&1; then
      local v; v=$($c -c 'import platform; print(platform.python_version())')
      if ver_ge "$v" "$MIN_PY"; then PY=$c; PY_VER=$v; return 0; fi
      OLD_PY=$v
    fi
  done
  return 1
}
install_python() {
  case $OS in
    mac) brew install python@3.14 ;;
    linux) sudo apt-get install -y python3 python3-venv && python3 -c 'import sys; assert sys.version_info >= (3,12)' \
             || { sudo apt-get install -y software-properties-common && sudo add-apt-repository -y ppa:deadsnakes/ppa \
                  && sudo apt-get update -y && sudo apt-get install -y python3.14 python3.14-venv; } ;;
    windows) "${WG[@]}" Python.Python.3.14 ;;
  esac
}
OLD_PY=""
if find_python; then congrats "Python $PY_VER" "(latest is 3.14 — anything ≥ $MIN_PY works)"; skip 10
else
  [[ -n $OLD_PY ]] && warn "Python $OLD_PY is too old for Django 6.1 — installing Python 3.14 alongside it."
  task 10 "Installing Python 3.14" "Install Python 3.14 from https://www.python.org/downloads/ and re-run." install_python
  hash -r; find_python || task_failed "Python" "Close this terminal, open a new one, and re-run ./setup.sh." 1
  ((INSTALLED += 1))
fi

# ============================================================================
# 3. Node.js                                                          (8%)
# ============================================================================
section "Node.js ≥ $MIN_NODE"
node_ok() { has node && ver_ge "$(node -v | tr -d v)" "$MIN_NODE"; }
install_node() {
  case $OS in
    mac) if brew list node >/dev/null 2>&1; then brew upgrade node; else brew install node; fi ;;
    linux) curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash - && sudo apt-get install -y nodejs ;;
    windows) "${WG[@]}" OpenJS.NodeJS.LTS ;;
  esac
}
if node_ok; then congrats "Node.js $(node -v)" "· npm $(npm -v)"; skip 8
else
  has node && warn "Node.js $(node -v) is too old for Vite 8 — updating to the latest."
  task 8 "Installing Node.js" "Install the LTS version from https://nodejs.org and re-run." install_node
  hash -r; node_ok || task_failed "Node.js" "Close this terminal, open a new one, and re-run ./setup.sh." 1
  ((INSTALLED += 1))
fi

# ============================================================================
# 4. Docker                                                          (20%)
# ============================================================================
section "Docker"
DOCKER=(docker)
docker_up() {
  if docker info >/dev/null 2>&1; then DOCKER=(docker); return 0; fi
  [[ $OS == linux ]] && sudo -n docker info >/dev/null 2>&1 && { DOCKER=(sudo docker); return 0; }
  return 1
}
compose_ok() { "${DOCKER[@]}" compose up --help 2>/dev/null | grep -- "--wait" >/dev/null; }
install_docker() {
  case $OS in
    mac) if brew list --cask docker-desktop >/dev/null 2>&1; then brew upgrade --cask docker-desktop; else brew install --cask docker-desktop; fi ;;
    linux) curl -fsSL https://get.docker.com | sudo sh && sudo usermod -aG docker "$USER" ;;
    windows) "${WG[@]}" Docker.DockerDesktop ;;
  esac
}
# Windows: Docker Desktop needs hardware virtualization + WSL ("Virtualization support
# not detected"). The doctor checks it and offers to run 'wsl --install'.
run_doctor() {
  local rc=0
  [[ ${1:-} == -DockerFailed ]] && warn "Docker Desktop didn't start — checking virtualization and WSL…"
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$ROOT/scripts/windows/docker-doctor.ps1")" "$@" || rc=$?
  case $rc in
    0) ;;
    10) printf "\n  ${C}Restart Windows, open Docker Desktop, then run ./setup.sh again.${N}\n\n"; exit 3 ;;
    *) printf "\n  ${R}✖  Docker can't run until virtualization is fixed${N} — follow the steps above, or run\n     fix-docker.cmd (it runs 'wsl --install'). Then run ./setup.sh again.\n\n"; exit 1 ;;
  esac
}
start_docker() {
  case $OS in
    mac) open -a Docker ;;
    linux) sudo systemctl start docker || sudo service docker start ;;
    windows) "/c/Program Files/Docker/Docker/Docker Desktop.exe" >/dev/null 2>&1 & ;;
  esac
  for _ in {1..90}; do docker_up && return 0; sleep 2; done
  return 1
}
if has docker && docker --version >/dev/null 2>&1; then
  congrats "$(docker --version | sed 's/, build.*//')"
  skip 14
else
  [[ $OS == mac ]] && need_sudo
  task 14 "Downloading Docker" "Install Docker Desktop from https://www.docker.com/products/docker-desktop and re-run." install_docker
  hash -r; ((INSTALLED += 1))
fi
if docker_up; then info "Docker engine is running"; skip 6
else
  [[ $OS == windows ]] && run_doctor
  [[ $OS != linux ]] && info "A Docker Desktop window may open — accept the terms and leave it running."
  # Windows: if the engine never comes up, run the doctor in "Docker failed" mode (offers wsl --install).
  [[ $OS == windows ]] && ON_FAIL="run_doctor -DockerFailed"
  task 6 "Starting Docker engine" "Open Docker Desktop, wait for 'Engine running', then re-run. Windows: if it says 'Virtualization support not detected', run fix-docker.cmd (runs 'wsl --install')." start_docker
  ON_FAIL=""
fi
if ! compose_ok; then
  warn "Your Docker is too old for this project — updating it."
  task 0 "Updating Docker" "Update Docker Desktop from its menu (Check for updates) and re-run." install_docker
  start_docker || true
fi

if [[ -t 0 ]]; then
  read -r -p "  ↳ Log in to Docker Hub? Optional; avoids anonymous download limits. [y/N] " REPLY || REPLY=""
  if [[ $REPLY =~ ^[Yy] ]]; then
    # docker login asks for your username + password/token itself; this script never sees or stores them.
    "${DOCKER[@]}" login || warn "Docker login failed — continuing without it (downloads still work)."
  fi
fi

# ============================================================================
# 5. PostgreSQL (Docker)                                             (22%)
# ============================================================================
section "PostgreSQL $POSTGRES_VERSION (Docker)"
if has psql || has postgres || [[ -d /Applications/Postgres.app ]]; then
  LOCAL_PG=$( (psql --version || postgres --version) 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)?' | head -1 || true)
  congrats "PostgreSQL ${LOCAL_PG:-(local)} on this computer" "— left untouched; the app runs its own PostgreSQL $POSTGRES_VERSION in Docker"
fi
EXISTING_DB=$("${DOCKER[@]}" inspect -f '{{.Config.Image}}' hackalem-db 2>/dev/null || true)
[[ $EXISTING_DB == "postgres:$POSTGRES_VERSION" ]] && congrats "Team database container" "(hackalem-db, $EXISTING_DB) — checking for the newest patch"
[[ -n $EXISTING_DB && $EXISTING_DB != "postgres:$POSTGRES_VERSION" ]] && warn "Your team database runs $EXISTING_DB — upgrading it to postgres:$POSTGRES_VERSION (data is kept)."

task 12 "Downloading PostgreSQL $POSTGRES_VERSION (latest patch)" \
  "Check your internet connection. Hitting download limits? Re-run and choose to log in to Docker Hub." \
  node scripts/db.js pull
task 10 "Starting the team database" \
  "Run 'docker compose logs db' to see why. Port problems are fixed automatically; re-run ./setup.sh." \
  node scripts/db.js up
{ grep '^NOTE: ' "$TASK_OUT" || true; } | sed 's/^NOTE: //' | while read -r line; do warn "$line"; done
DB_READY=$({ grep '^READY ' "$TASK_OUT" || true; } | sed 's/^READY //')
info "${DB_READY:-database ready}"

# ============================================================================
# 6. Django backend                                                  (18%)
# ============================================================================
section "Django backend"
VENV_PY=".venv/bin/python"; [[ -f .venv/Scripts/python.exe ]] && VENV_PY=".venv/Scripts/python.exe"
if [[ -x $VENV_PY ]] && ! $VENV_PY -c "import sys; exit(sys.version_info < (${MIN_PY/./,}))" 2>/dev/null; then
  warn "Existing .venv uses an old Python — rebuilding it."; rm -rf .venv
fi
make_venv() { $PY -m venv .venv; }
if [[ -d .venv ]]; then skip 4; else task 4 "Creating Python environment (.venv)" "Linux: sudo apt-get install python3-venv. Otherwise delete the .venv folder and re-run." make_venv; fi
VENV_PY=".venv/bin/python"; [[ -f .venv/Scripts/python.exe ]] && VENV_PY=".venv/Scripts/python.exe"

DJANGO_BEFORE=$($VENV_PY -c "import django; print(django.get_version())" 2>/dev/null || true)
pip_install() {
  $VENV_PY -m pip install --upgrade pip &&
  $VENV_PY -m pip install --upgrade -r backend/requirements.txt
}
task 10 "Installing Django + Python packages (latest)" "Check your internet connection, then re-run. Details are in logs/setup.log." pip_install
DJANGO_NOW=$($VENV_PY -c "import django; print(django.get_version())")
if [[ -n $DJANGO_BEFORE && $DJANGO_BEFORE == "$DJANGO_NOW" ]]; then congrats "Django $DJANGO_NOW" "(already the latest)"
elif [[ -n $DJANGO_BEFORE ]]; then info "Django updated $DJANGO_BEFORE → $DJANGO_NOW"
else info "Django $DJANGO_NOW installed"; fi

migrate() { $VENV_PY backend/manage.py migrate --noinput; }
task 4 "Connecting Django to the database" "The database may not be ready yet — wait a few seconds and re-run ./setup.sh." migrate
load_data() { $VENV_PY backend/manage.py load_open_data; }
task 0 "Loading map, population & greenery data" "Run 'npm run data:load' to see the error, then re-run ./setup.sh." load_data

# ============================================================================
# 7. React frontend                                                  (12%)
# ============================================================================
section "React frontend"
npm_install() { cd frontend && npm install --no-fund --no-audit; }
task 12 "Installing React + Vite packages" "Check your internet connection. If it keeps failing, delete frontend/node_modules and re-run." npm_install

# ============================================================================
# 8. Done                                                             (2%)
# ============================================================================
DONE=100
printf "\n  ${V}%s${N} ${B}100%%${N}\n\n" "$(bar 100)"
if ((INSTALLED == 0 && ALREADY > 0)); then
  printf "  🚀 $(rainbow "Congrats! Your computer already had everything!") ${D}Nothing new to install.${N}\n"
else
  printf "  🚀 $(rainbow "Setup complete!") ${D}%d tool(s) installed, %d already present.${N}\n" "$INSTALLED" "$ALREADY"
fi
printf "  ${D}Next time, just run:${N} ${C}${B}npm start${N}\n\n"
rm -f "$TASK_OUT"
exec node "$ROOT/scripts/start.js"
