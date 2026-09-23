# ============================================================================
#  HackAlem / QBERS - native Windows setup (called by setup.cmd)
#  Uses winget to install Python, Node.js and Docker Desktop, starts PostgreSQL
#  in Docker with the team database, installs Django + React dependencies, then
#  launches the app. Safe to re-run any time. All settings come from .env.
# ============================================================================
# Native tools report failure via $LASTEXITCODE, which we check after each call.
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot

function Step($msg) { Write-Host "`n> $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  [ok] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  [!] $msg" -ForegroundColor Yellow }
function Die($msg)  { Write-Host "`n  [x] $msg`n" -ForegroundColor Red; exit 1 }
function Has($cmd)  { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [Environment]::GetEnvironmentVariable("Path", "User")
}

function Winget-Install($id, $extra = @()) {
  winget list --id $id -e --accept-source-agreements *> $null
  if ($LASTEXITCODE -eq 0) { Ok "$id already installed"; return }
  Write-Host "  installing $id ..."
  winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements @extra
  if ($LASTEXITCODE -ne 0) { Die "winget could not install $id (exit $LASTEXITCODE)." }
  Refresh-Path
}

Write-Host @"

   QBERS  //  HackAlem local environment setup (Windows)

"@ -ForegroundColor Magenta

if (-not (Test-Path .env)) { Die ".env is missing. It's committed to the repo - run 'git pull' (or re-clone) and try again." }
$Cfg = @{}
foreach ($line in Get-Content .env) {
  if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$') {
    $k = $Matches[1]; $v = $Matches[2]
    if ($v -match '^([''"])(.*)\1$') { $v = $Matches[2] }
    $Cfg[$k] = $v
  }
}

# ---------------------------------------------------------------------------
# 1. winget + software
# ---------------------------------------------------------------------------
Step "winget"
if (-not (Has winget)) {
  Die "winget not found. Install 'App Installer' from the Microsoft Store, then run setup.cmd again."
}
Ok "winget $(winget --version)"

$DockerBin = "C:\Program Files\Docker\Docker\resources\bin"
$DockerApp = "C:\Program Files\Docker\Docker\Docker Desktop.exe"

Step "Python, Node.js, Docker Desktop (Windows may ask for permission)"
Winget-Install "Python.Python.3.12"
Winget-Install "OpenJS.NodeJS.LTS"
Winget-Install "Docker.DockerDesktop"
$env:Path = "$DockerBin;C:\Program Files\nodejs;$env:Path"

# Prefer the py launcher; the bare "python" can be the Microsoft Store stub.
if (Has py) { $PyExe = "py"; $PyArgs = @("-3") }
elseif (Has python) { $PyExe = "python"; $PyArgs = @() }
else { Die "Python not found. Close this window, open a new Command Prompt, and run setup.cmd again." }
function Python { & $PyExe @PyArgs @args }
Ok (Python --version)
if (-not (Has node)) { Die "Node.js not found. Close this window, open a new Command Prompt, and run setup.cmd again." }
Ok "node $(node -v)  npm $(npm.cmd -v)"

# ---------------------------------------------------------------------------
# 2. Docker engine + login
# ---------------------------------------------------------------------------
Step "Docker"
if (-not (Has docker)) { Die "Docker not found. Close this window, open a new Command Prompt, and run setup.cmd again." }
function Docker-Up { docker info *> $null; return ($LASTEXITCODE -eq 0) }
if (-not (Docker-Up)) {
  Warn "Starting Docker Desktop... on first launch accept its terms; it may ask to install WSL or restart."
  if (Test-Path $DockerApp) { Start-Process $DockerApp }
  for ($i = 0; $i -lt 90; $i++) { if (Docker-Up) { break }; Start-Sleep 2 }
}
if (-not (Docker-Up)) {
  Die "Docker didn't start. Open Docker Desktop, wait for 'Engine running' (restart Windows if it asks), then run setup.cmd again."
}
Ok (docker --version)

$ans = Read-Host "  Log in to Docker Hub? Optional; avoids anonymous download limits. [y/N]"
if ($ans -match '^[Yy]') {
  # docker login asks for your username + password/token itself; nothing is stored by this script.
  docker login
  if ($LASTEXITCODE -ne 0) { Warn "Docker login failed - continuing without it." }
}

# ---------------------------------------------------------------------------
# 3. PostgreSQL in Docker
# ---------------------------------------------------------------------------
Step "PostgreSQL $($Cfg.POSTGRES_VERSION) (Docker) -> 127.0.0.1:$($Cfg.POSTGRES_PORT)"
docker compose up -d --wait db
if ($LASTEXITCODE -ne 0) { Die "Database container failed - run 'docker compose logs db' to see why." }
docker compose exec -T db psql -U $Cfg.POSTGRES_USER -d $Cfg.POSTGRES_DB -tAc "SELECT 1" *> $null
if ($LASTEXITCODE -ne 0) { Die "Could not connect to database '$($Cfg.POSTGRES_DB)' as '$($Cfg.POSTGRES_USER)'." }
Ok "database '$($Cfg.POSTGRES_DB)' ready (user '$($Cfg.POSTGRES_USER)')"

# ---------------------------------------------------------------------------
# 4. Django backend
# ---------------------------------------------------------------------------
Step "Django backend"
if (-not (Test-Path .venv)) { Python -m venv .venv }
$VenvPy = ".\.venv\Scripts\python.exe"
& $VenvPy -m pip install --quiet --upgrade pip
& $VenvPy -m pip install --quiet -r backend\requirements.txt
if ($LASTEXITCODE -ne 0) { Die "pip install failed." }
& $VenvPy backend\manage.py migrate --noinput
if ($LASTEXITCODE -ne 0) { Die "Database migration failed." }
Ok "Django connected + migrated"

# ---------------------------------------------------------------------------
# 5. React frontend
# ---------------------------------------------------------------------------
Step "React frontend"
Push-Location frontend
npm.cmd install --no-fund --no-audit --loglevel=error
$npmExit = $LASTEXITCODE
Pop-Location
if ($npmExit -ne 0) { Die "npm install failed." }
Ok "npm packages installed"

# ---------------------------------------------------------------------------
# 6. Launch
# ---------------------------------------------------------------------------
Write-Host "`n[ok] Setup complete. Next time, just run:  npm start`n" -ForegroundColor Green
node scripts\start.js
