# ============================================================================
#  HackAlem / QBERS - native Windows setup (called by setup.cmd)
#  Uses winget to install Python, Node.js and Docker Desktop, starts PostgreSQL
#  18 in Docker with the team database, installs Django + React dependencies,
#  then launches the app. Safe to re-run any time. All settings come from .env.
#  Full output of every step goes to logs\setup.log.
# ============================================================================
# Native tools report failure via exit codes, which every step checks.
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot

$MinPy = [version]"3.12"     # Django 6.1
$MinNode = [version]"22.12"  # Vite 8

$LogDir = Join-Path $PSScriptRoot "logs"
New-Item -ItemType Directory -Force $LogDir | Out-Null
$Log = Join-Path $LogDir "setup.log"
$Out = Join-Path $LogDir ".task.out"
$Err = Join-Path $LogDir ".task.err"
Set-Content $Log "HackAlem setup log - $(Get-Date)"

$Full = [string][char]0x2588; $Empty = [string][char]0x2591
$Spin = @("|", "/", "-", "\")
$Rainbow = @("Red", "Yellow", "Green", "Cyan", "Blue", "Magenta")
$script:Done = 0; $script:Already = 0; $script:Installed = 0

function Section($msg) { Write-Host "`n> $msg" -ForegroundColor Cyan }
function Info($msg)    { Write-Host "  -  $msg" -ForegroundColor DarkGray }
function Warn($msg)    { Write-Host "  !  $msg" -ForegroundColor Yellow }
function Has($cmd)     { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Bar([int]$pct) { $f = [int]($pct * 22 / 100); ($Full * $f) + ($Empty * (22 - $f)) }
function Clear-Line { Write-Host -NoNewline ("`r" + (" " * ([Console]::WindowWidth - 1)) + "`r") }

function Rainbow($text) {
  for ($i = 0; $i -lt $text.Length; $i++) { Write-Host -NoNewline $text[$i] -ForegroundColor $Rainbow[$i % $Rainbow.Length] }
}
function Congrats($what, $note = "") {
  Write-Host -NoNewline "  *  "; Rainbow "Already installed:"; Write-Host -NoNewline " $what " -ForegroundColor Green
  Write-Host $note -ForegroundColor DarkGray
  $script:Already++
}

function Stop-Setup($msg) { Clear-Line; Write-Host "`n  X  $msg`n" -ForegroundColor Red; exit 1 }

function Task-Failed($label, $hint, $code) {
  Clear-Line
  Write-Host "  X  $label failed (exit code $code)" -ForegroundColor Red
  Write-Host "`n  -- last lines of output ---------------------------------" -ForegroundColor DarkGray
  $lines = @(); foreach ($f in $Err, $Out) { if (Test-Path $f) { $lines += Get-Content $f } }
  $lines | Select-Object -Last 15 | ForEach-Object { Write-Host "  | $_" -ForegroundColor DarkGray }
  Write-Host "  ---------------------------------------------------------`n" -ForegroundColor DarkGray
  Write-Host -NoNewline "  How to fix: " -ForegroundColor Yellow; Write-Host $hint
  Write-Host "  Full log: logs\setup.log - then run setup.cmd again; finished steps are skipped.`n" -ForegroundColor DarkGray
  exit 1
}

function Show-Progress($label, $tick, $pct, $secs) {
  $dots = "." * ([int][Math]::Floor($tick / 3) % 4)
  Write-Host -NoNewline ("`r  {0} {1}{2,-3} " -f $Spin[$tick % 4], $label, $dots) -ForegroundColor Cyan
  Write-Host -NoNewline (Bar $pct) -ForegroundColor Magenta
  Write-Host -NoNewline (" {0,3}%  {1}s " -f $pct, $secs)
}

function Show-Done($label, $secs) {
  Clear-Line
  Write-Host -NoNewline "  +  " -ForegroundColor Green
  Write-Host -NoNewline ("{0,-46}" -f "$label ($($secs)s)")
  Write-Host -NoNewline (Bar $script:Done) -ForegroundColor Magenta
  Write-Host (" {0,3}%" -f $script:Done)
}

# Task <weight> <label> <how-to-fix> <exe> <args...>
# Runs a program in the background with an animated "..." preloader and the
# overall percentage; its output goes to logs\setup.log. Stops setup on failure.
function Task([int]$Weight, [string]$Label, [string]$Hint, [string]$Exe, [string[]]$ArgList = @(), [int[]]$OkCodes = @(0)) {
  $from = $script:Done; $to = $from + $Weight; $span = [Math]::Max(0, $Weight - 1)
  Add-Content $Log "`n### $Label`n> $Exe $($ArgList -join ' ')"
  Remove-Item $Out, $Err -ErrorAction SilentlyContinue
  $sw = [Diagnostics.Stopwatch]::StartNew()
  try {
    $p = Start-Process -FilePath $Exe -ArgumentList $ArgList -WorkingDirectory $PSScriptRoot -NoNewWindow -PassThru `
      -RedirectStandardOutput $Out -RedirectStandardError $Err -ErrorAction Stop
  } catch {
    Set-Content $Err "Could not start '$Exe': $_"
    Task-Failed $Label $Hint "n/a"
  }
  $null = $p.Handle   # needed so ExitCode is populated after the process ends
  $tick = 0
  while (-not $p.HasExited) {
    Show-Progress $Label $tick ($from + [int]($span * $tick / ($tick + 40))) ([int]$sw.Elapsed.TotalSeconds)
    Start-Sleep -Milliseconds 150; $tick++
  }
  $p.WaitForExit()
  foreach ($f in $Out, $Err) { if (Test-Path $f) { Get-Content $f | Add-Content $Log } }
  if ($OkCodes -notcontains $p.ExitCode) { Task-Failed $Label $Hint $p.ExitCode }
  $script:Done = $to
  Show-Done $Label ([int]$sw.Elapsed.TotalSeconds)
}

# Wait-Task: same preloader while polling a condition (e.g. Docker engine starting).
function Wait-Task([int]$Weight, [string]$Label, [string]$Hint, [scriptblock]$Check, [int]$TimeoutSec = 180, [scriptblock]$OnTimeout = $null) {
  $from = $script:Done; $span = [Math]::Max(0, $Weight - 1)
  $sw = [Diagnostics.Stopwatch]::StartNew(); $tick = 0
  while (-not (& $Check)) {
    if ($sw.Elapsed.TotalSeconds -gt $TimeoutSec) {
      if ($OnTimeout) { Clear-Line; & $OnTimeout }   # may fix the problem and exit
      Set-Content $Err "Timed out after $TimeoutSec seconds."; Remove-Item $Out -ErrorAction SilentlyContinue
      Task-Failed $Label $Hint "timeout"
    }
    for ($i = 0; $i -lt 10; $i++) {
      Show-Progress $Label $tick ($from + [int]($span * $tick / ($tick + 60))) ([int]$sw.Elapsed.TotalSeconds)
      Start-Sleep -Milliseconds 200; $tick++
    }
  }
  $script:Done = $from + $Weight
  Show-Done $Label ([int]$sw.Elapsed.TotalSeconds)
}

function Skip([int]$Weight) { $script:Done += $Weight }

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [Environment]::GetEnvironmentVariable("Path", "User") + ";" +
              "C:\Program Files\Docker\Docker\resources\bin;C:\Program Files\nodejs"
}

# Install a package with winget, or upgrade it if an older copy is already there.
function Winget-Task([int]$Weight, $Label, $Hint, $Id) {
  winget list --id $Id -e --accept-source-agreements *> $null
  $verb = if ($LASTEXITCODE -eq 0) { "upgrade" } else { "install" }
  # Also OK: 0x8A15002B "no newer version" and 0x8A150061 "already installed".
  Task $Weight $Label $Hint "winget" @($verb, "--id", $Id, "-e", "--silent", "--accept-package-agreements", "--accept-source-agreements") @(0, -1978335189, -1978335135)
  Refresh-Path
  $script:Installed++
}

# ---------------------------------------------------------------------------
Write-Host @"

   QBERS  //  HackAlem local environment setup (Windows)

"@ -ForegroundColor Magenta

if (-not (Test-Path .env)) { Stop-Setup ".env is missing. It's committed to the repo - run 'git pull' (or re-clone) and try again." }
$Cfg = @{}
foreach ($file in ".env", ".env.local") {
  if (-not (Test-Path $file)) { continue }
  foreach ($line in Get-Content $file) {
    if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$') {
      $k = $Matches[1]; $v = $Matches[2]
      if ($v -match '^([''"])(.*)\1$') { $v = $Matches[2] }
      $Cfg[$k] = $v
    }
  }
}
Refresh-Path
Info "Log: logs\setup.log"

# ============================================================================
# 1. winget                                                            (8%)
# ============================================================================
Section "Package manager"
if (-not (Has winget)) { Stop-Setup "winget not found. Install 'App Installer' from the Microsoft Store, then run setup.cmd again." }
Congrats "winget $(winget --version)"; Skip 8

# ============================================================================
# 2. Python                                                           (10%)
# ============================================================================
Section "Python >= $MinPy"
function Find-Python {
  foreach ($c in @(@("py", "-3.14"), @("py", "-3.13"), @("py", "-3.12"), @("py", "-3"), @("python"))) {
    if (-not (Has $c[0])) { continue }
    $pyArgs = @($c | Select-Object -Skip 1)
    $v = & $c[0] @pyArgs -c "import platform; print(platform.python_version())" 2>$null
    if ($LASTEXITCODE -eq 0 -and $v -and ([version]$v -ge $MinPy)) {
      $script:PyExe = $c[0]; $script:PyArgs = $pyArgs; $script:PyVer = $v; return $true
    }
    if ($v) { $script:OldPy = $v }
  }
  return $false
}
if (Find-Python) { Congrats "Python $PyVer" "(latest is 3.14 - anything >= $MinPy works)"; Skip 10 }
else {
  if ($OldPy) { Warn "Python $OldPy is too old for Django 6.1 - installing Python 3.14 alongside it." }
  Winget-Task 10 "Installing Python 3.14" "Install Python 3.14 from https://www.python.org/downloads/ and run setup.cmd again." "Python.Python.3.14"
  if (-not (Find-Python)) { Stop-Setup "Python installed but not found yet. Close this window, open a new Command Prompt, and run setup.cmd again." }
}

# ============================================================================
# 3. Node.js                                                           (8%)
# ============================================================================
Section "Node.js >= $MinNode"
function Node-Ok { (Has node) -and ([version]((node -v) -replace '^v', '') -ge $MinNode) }
if (Node-Ok) { Congrats "Node.js $(node -v)" "- npm $(npm.cmd -v)"; Skip 8 }
else {
  if (Has node) { Warn "Node.js $(node -v) is too old for Vite 8 - updating to the latest LTS." }
  Winget-Task 8 "Installing Node.js LTS" "Install the LTS version from https://nodejs.org and run setup.cmd again." "OpenJS.NodeJS.LTS"
  if (-not (Node-Ok)) { Stop-Setup "Node.js installed but not found yet. Close this window, open a new Command Prompt, and run setup.cmd again." }
}

# ============================================================================
# 4. Docker                                                           (20%)
# ============================================================================
Section "Docker"
$DockerApp = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
function Docker-Up { docker info *> $null; return ($LASTEXITCODE -eq 0) }
if ((Has docker) -or (Test-Path $DockerApp)) { Congrats "$((docker --version) -replace ', build.*', '')"; Skip 14 }
else {
  Winget-Task 14 "Downloading Docker Desktop" "Install Docker Desktop from https://www.docker.com/products/docker-desktop and run setup.cmd again." "Docker.DockerDesktop"
}
# Docker Desktop can't start without hardware virtualization ("Virtualization support
# not detected"). Check it before waiting on the engine, and offer to fix it.
# -DockerFailed: Docker didn't come up even though checks may pass - the doctor
# then offers 'wsl --install', which is what fixes it on most machines.
function Run-Doctor([switch]$DockerFailed) {
  $extra = @(); if ($DockerFailed) { $extra = @("-DockerFailed"); Warn "Docker Desktop didn't start - checking virtualization and WSL..." }
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\scripts\windows\docker-doctor.ps1" @extra
  switch ($LASTEXITCODE) {
    0 { return }
    10 { Write-Host "`n  Restart Windows, open Docker Desktop, then run setup.cmd again.`n" -ForegroundColor Cyan; exit 3 }
    20 { Stop-Setup "Turn on virtualization in BIOS/UEFI (steps above), then run setup.cmd again." }
    21 { Stop-Setup "Enable nested virtualization for this VM (steps above), then run setup.cmd again." }
    default { Stop-Setup "Docker can't run until virtualization is fixed - see 'Virtualization support not detected' in the README." }
  }
}
# While waiting for the engine, check Docker's log every ~10s: if it reports the
# virtualization/WSL error, the engine will never start - go straight to the fix.
$script:Polls = 0
function Docker-Up-Or-Fix {
  if (Docker-Up) { return $true }
  $script:Polls++
  if ($script:Polls % 5 -eq 0) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\scripts\windows\docker-doctor.ps1" -LogCheck
    if ($LASTEXITCODE -ne 0) { Clear-Line; Run-Doctor -DockerFailed; Stop-Setup "Docker still can't start - see 'Virtualization support not detected' in the README." }
  }
  return $false
}
$DockerHint = "Open Docker Desktop and wait for 'Engine running'. If it says 'Virtualization support not detected', run fix-docker.cmd (it runs 'wsl --install')."
if (Docker-Up) { Info "Docker engine is running"; Skip 6 }
else {
  Run-Doctor
  Info "Docker Desktop is opening - accept its terms; it may ask to install WSL or restart Windows."
  if (Test-Path $DockerApp) { Start-Process $DockerApp }
  Wait-Task 6 "Starting Docker engine" $DockerHint { Docker-Up-Or-Fix } 300 { Run-Doctor -DockerFailed }
}
if (-not (docker compose up --help 2>$null | Select-String -Pattern "--wait" -SimpleMatch -Quiet)) {
  Warn "Your Docker is too old for this project - updating it."
  Winget-Task 0 "Updating Docker Desktop" "Update Docker Desktop from its menu (Check for updates) and run setup.cmd again." "Docker.DockerDesktop"
  Wait-Task 0 "Restarting Docker engine" $DockerHint { Docker-Up-Or-Fix } 300 { Run-Doctor -DockerFailed }
}

$ans = Read-Host "  Log in to Docker Hub? Optional; avoids anonymous download limits. [y/N]"
if ($ans -match '^[Yy]') {
  # docker login asks for your username + password/token itself; this script never sees or stores them.
  docker login
  if ($LASTEXITCODE -ne 0) { Warn "Docker login failed - continuing without it (downloads still work)." }
}

# ============================================================================
# 5. PostgreSQL (Docker)                                              (22%)
# ============================================================================
Section "PostgreSQL $($Cfg.POSTGRES_VERSION) (Docker)"
if ((Has psql) -or (Test-Path "C:\Program Files\PostgreSQL")) {
  $localPg = if (Has psql) { ((psql --version) -replace '[^\d\.]', ' ').Trim().Split(' ')[0] } else { "(local)" }
  Congrats "PostgreSQL $localPg on this computer" "- left untouched; the app runs its own PostgreSQL $($Cfg.POSTGRES_VERSION) in Docker"
}
$existing = docker inspect -f '{{.Config.Image}}' hackalem-db 2>$null
if ($LASTEXITCODE -eq 0 -and $existing) {
  if ($existing -eq "postgres:$($Cfg.POSTGRES_VERSION)") { Congrats "Team database container" "(hackalem-db, $existing) - checking for the newest patch" }
  else { Warn "Your team database runs $existing - upgrading it to postgres:$($Cfg.POSTGRES_VERSION) (data is kept)." }
}
Task 12 "Downloading PostgreSQL $($Cfg.POSTGRES_VERSION) (latest patch)" "Check your internet connection. Hitting download limits? Run setup.cmd again and log in to Docker Hub." "node" @("scripts\db.js", "pull")
Task 10 "Starting the team database" "Run 'docker compose logs db' to see why. Port problems are fixed automatically; run setup.cmd again." "node" @("scripts\db.js", "up")
foreach ($line in (Get-Content $Out)) {
  if ($line -like "NOTE: *") { Warn $line.Substring(6) }
  elseif ($line -like "READY *") { Info $line.Substring(6) }
}

# ============================================================================
# 6. Django backend                                                   (18%)
# ============================================================================
Section "Django backend"
$VenvPy = ".\.venv\Scripts\python.exe"
if (Test-Path $VenvPy) {
  & $VenvPy -c "import sys; exit(sys.version_info < ($($MinPy.Major),$($MinPy.Minor)))" 2>$null
  if ($LASTEXITCODE -ne 0) { Warn "Existing .venv uses an old Python - rebuilding it."; Remove-Item -Recurse -Force .venv }
}
if (Test-Path .venv) { Skip 4 }
else { Task 4 "Creating Python environment (.venv)" "Delete the .venv folder and run setup.cmd again." $PyExe (@($PyArgs) + @("-m", "venv", ".venv")) }

$djangoBefore = & $VenvPy -c "import django; print(django.get_version())" 2>$null
if ($LASTEXITCODE -ne 0) { $djangoBefore = "" }
Task 3 "Updating pip" "Check your internet connection, then run setup.cmd again." $VenvPy @("-m", "pip", "install", "--upgrade", "pip")
Task 7 "Installing Django + Python packages (latest)" "Check your internet connection, then run setup.cmd again. Details are in logs\setup.log." $VenvPy @("-m", "pip", "install", "--upgrade", "-r", "backend\requirements.txt")
$djangoNow = & $VenvPy -c "import django; print(django.get_version())"
if ($djangoBefore -and $djangoBefore -eq $djangoNow) { Congrats "Django $djangoNow" "(already the latest)" }
elseif ($djangoBefore) { Info "Django updated $djangoBefore -> $djangoNow" }
else { Info "Django $djangoNow installed" }
Task 4 "Connecting Django to the database" "The database may not be ready yet - wait a few seconds and run setup.cmd again." $VenvPy @("backend\manage.py", "migrate", "--noinput")

# ============================================================================
# 7. React frontend                                                   (12%)
# ============================================================================
Section "React frontend"
Task 12 "Installing React + Vite packages" "Check your internet connection. If it keeps failing, delete frontend\node_modules and run setup.cmd again." "cmd.exe" @("/c", "cd frontend && npm install --no-fund --no-audit")

# ============================================================================
# 8. Done                                                              (2%)
# ============================================================================
$script:Done = 100
Write-Host ""; Write-Host -NoNewline "  "; Write-Host -NoNewline (Bar 100) -ForegroundColor Magenta; Write-Host " 100%`n"
Write-Host -NoNewline "  "
if ($script:Installed -eq 0 -and $script:Already -gt 0) {
  Rainbow "Congrats! Your computer already had everything!"; Write-Host " Nothing new to install." -ForegroundColor DarkGray
} else {
  Rainbow "Setup complete!"; Write-Host " $($script:Installed) tool(s) installed, $($script:Already) already present." -ForegroundColor DarkGray
}
Write-Host -NoNewline "  Next time, just run: " -ForegroundColor DarkGray; Write-Host "npm start`n" -ForegroundColor Cyan
Remove-Item $Out, $Err -ErrorAction SilentlyContinue
node scripts\start.js
