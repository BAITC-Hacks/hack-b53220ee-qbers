#!/usr/bin/env bash
# Starts Django (:8000, or next free port) and React/Vite (:5173), then opens the browser.
# Run ./setup.sh once first; afterwards ./run.sh is enough.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

C="\033[38;5;51m"; G="\033[38;5;84m"; R="\033[38;5;203m"; N="\033[0m"

[[ -d .venv && -d frontend/node_modules && -f .env ]] || { printf "${R}Run ./setup.sh first.${N}\n"; exit 1; }

# Make sure Postgres is up (macOS / Linux; Windows runs it as a service).
if command -v brew >/dev/null 2>&1 && brew list --versions postgresql@16 >/dev/null 2>&1; then
  export PATH="$(brew --prefix postgresql@16)/bin:$PATH"
  pg_isready -h localhost -q 2>/dev/null || brew services start postgresql@16 >/dev/null
elif command -v service >/dev/null 2>&1 && [[ "$(uname -s)" == Linux* ]]; then
  pg_isready -h localhost -q 2>/dev/null || sudo service postgresql start
fi

if [[ -f .venv/bin/activate ]]; then source .venv/bin/activate; else source .venv/Scripts/activate; fi
python backend/manage.py migrate --noinput >/dev/null

# Use port 8000, or the next free one if something else (e.g. Docker) holds it.
port_busy() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }
export DJANGO_PORT=8000
while port_busy "$DJANGO_PORT"; do DJANGO_PORT=$((DJANGO_PORT + 1)); done

mkdir -p logs
python backend/manage.py runserver "127.0.0.1:$DJANGO_PORT" >logs/django.log 2>&1 &
DJANGO_PID=$!
trap 'pkill -P $DJANGO_PID 2>/dev/null; kill $DJANGO_PID 2>/dev/null || true' EXIT INT TERM

for _ in {1..30}; do
  curl -fs "http://127.0.0.1:$DJANGO_PORT/api/health/" >/dev/null 2>&1 && break
  kill -0 $DJANGO_PID 2>/dev/null || { printf "${R}Django failed to start — see logs/django.log${N}\n"; tail -20 logs/django.log; exit 1; }
  sleep 1
done

printf "\n${G}●${N} Django API   ${C}http://127.0.0.1:$DJANGO_PORT/api/health/${N}  (logs/django.log)\n"
printf "${G}●${N} Web app      ${C}http://localhost:5173${N}\n"
printf "  Press Ctrl+C to stop both servers.\n\n"

cd frontend
npx vite --open
