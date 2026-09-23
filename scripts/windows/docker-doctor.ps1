# ============================================================================
#  Docker doctor (Windows) - fixes "Virtualization support not detected"
#
#  Docker Desktop needs three things:
#    1. CPU virtualization (Intel VT-x / AMD-V "SVM") switched on in BIOS/UEFI
#    2. WSL 2 installed (brings Virtual Machine Platform + Windows Subsystem
#       for Linux) - `wsl --install` is the fix that works for most people
#    3. The Windows hypervisor set to start at boot
#  This script checks all three - plus Docker Desktop's own logs for the error -
#  fixes 2 and 3 for you (with your permission and an admin prompt), and
#  explains how to do 1, which only you can change.
#
#  Usage:  fix-docker.cmd                   (interactive: check, offer fixes)
#          docker-doctor.ps1 -CheckOnly     (report only, no prompts)
#          docker-doctor.ps1 -DockerFailed  (Docker didn't start: also offer
#                                            to (re)install WSL if checks pass)
#          docker-doctor.ps1 -LogCheck      (fast: exit 1 if Docker logged the
#                                            error in the last 5 minutes)
#  Exit codes: 0 ready | 10 restart needed | 20 BIOS setting needed
#              21 running in a VM without nested virtualization | 1 other
# ============================================================================
param([switch]$CheckOnly, [switch]$Elevated, [switch]$DockerFailed, [switch]$LogCheck)
$ErrorActionPreference = "Continue"

function Say($msg, $color = "Gray") { Write-Host "  $msg" -ForegroundColor $color }
function Is-Admin {
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Feature-On($name) {
  $f = Get-CimInstance Win32_OptionalFeature -Filter "Name='$name'" -ErrorAction SilentlyContinue
  return [bool]($f -and $f.InstallState -eq 1)
}
# Did Docker Desktop itself log "Virtualization support not detected" / missing WSL?
function Docker-Logged-Error([int]$Minutes = 2880) {
  $logDir = Join-Path $env:LOCALAPPDATA "Docker\log"
  if (-not (Test-Path $logDir)) { return $null }
  $recent = Get-ChildItem $logDir -Recurse -Filter *.log -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-$Minutes) } |
    Sort-Object LastWriteTime -Descending | Select-Object -First 8
  if (-not $recent) { return $null }
  $hit = $recent | Select-String -List -Pattern @(
    "virtuali[sz]ation support", "virtualization.*not (detected|enabled)", "HCS_E_HYPERV_NOT_INSTALLED",
    "WSL.*(not installed|needs updating|kernel)", "wsl --install", "wsl --update"
  ) -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($hit) { return $hit.Line.Trim() } else { return $null }
}

function Wsl-Ready {
  if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) { return $false }
  wsl.exe --status *> $null
  return ($LASTEXITCODE -eq 0)
}

if ($LogCheck) { if (Docker-Logged-Error -Minutes 5) { exit 1 } else { exit 0 } }

# ---------------------------------------------------------------------------
# Elevated half: apply the fixes (called by the interactive half via UAC)
# ---------------------------------------------------------------------------
if ($Elevated) {
  Say "Applying fixes (this window closes by itself)..." Cyan
  $failed = $false
  # 1) wsl --install: installs WSL 2 and switches on Virtual Machine Platform +
  #    Windows Subsystem for Linux in one go. --no-distribution skips Ubuntu,
  #    which Docker doesn't need; older Windows builds don't know that flag.
  Say "Installing WSL (wsl --install) ..."
  wsl.exe --install --no-distribution
  $wslCode = $LASTEXITCODE
  if ($wslCode -ne 0) {
    Say "Retrying with plain 'wsl --install' (older Windows) ..."
    wsl.exe --install
    $wslCode = $LASTEXITCODE
  }
  # 2) Fallback: switch the two Windows features on directly.
  if ($wslCode -ne 0) {
    foreach ($feat in "VirtualMachinePlatform", "Microsoft-Windows-Subsystem-Linux") {
      Say "Enabling Windows feature $feat ..."
      dism.exe /online /enable-feature /featurename:$feat /all /norestart | Out-Null
      # 0 = done, 3010 = done but restart required
      if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 3010) { Say "  failed (dism exit $LASTEXITCODE)" Red; $failed = $true }
    }
  }
  Say "Setting the Windows hypervisor to start at boot ..."
  bcdedit.exe /set hypervisorlaunchtype auto | Out-Null
  if ($LASTEXITCODE -ne 0) { Say "  failed (bcdedit exit $LASTEXITCODE)" Red; $failed = $true }
  Say "Updating WSL ..."
  wsl.exe --update *> $null      # may only finish after the restart - that's fine
  wsl.exe --set-default-version 2 *> $null
  Start-Sleep -Seconds 2
  if ($failed) { exit 1 } else { exit 10 }
}

# ---------------------------------------------------------------------------
# Diagnose
# ---------------------------------------------------------------------------
$cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
$cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
$model = "$($cs.Manufacturer) $($cs.Model)".Trim()
# When the hypervisor is already running, Windows hides the firmware flag - so check it first.
$hypervisor = [bool]$cs.HypervisorPresent
$firmware = $hypervisor -or [bool]$cpu.VirtualizationFirmwareEnabled
$inVm = $model -match 'Virtual|VMware|VirtualBox|QEMU|KVM|Parallels|Xen'
$vmp = Feature-On "VirtualMachinePlatform"
$wslFeature = Feature-On "Microsoft-Windows-Subsystem-Linux"
$wsl = Wsl-Ready

Write-Host "`n  Docker doctor - checking virtualization`n" -ForegroundColor Magenta
function Row($ok, $label, $detail = "") {
  if ($ok) { Write-Host "   [ok] " -ForegroundColor Green -NoNewline } else { Write-Host "   [!!] " -ForegroundColor Red -NoNewline }
  Write-Host $label -NoNewline; Write-Host "  $detail" -ForegroundColor DarkGray
}
Row $firmware "CPU virtualization enabled in BIOS/UEFI" "$($cpu.Name)"
Row $vmp "Windows feature: Virtual Machine Platform"
Row $wslFeature "Windows feature: Windows Subsystem for Linux"
Row $hypervisor "Windows hypervisor running"
Row $wsl "WSL 2 installed and working"
$dockerError = Docker-Logged-Error
Row (-not $dockerError) "Docker Desktop log free of virtualization/WSL errors" $(if ($dockerError) { $dockerError.Substring(0, [Math]::Min(70, $dockerError.Length)) })
Write-Host ""

$needsFix = (-not $vmp) -or (-not $wslFeature) -or (-not $wsl) -or ($firmware -and -not $hypervisor)
# Everything looks enabled but Docker still reports the error (or didn't start):
# reinstalling WSL is what fixes it in practice.
$repairWsl = (-not $needsFix) -and $firmware -and ($dockerError -or $DockerFailed)
if ($repairWsl) { $needsFix = $true }

# ---- Case 1: virtualization off in firmware (only the user can change this) ----
if (-not $firmware) {
  if ($inVm) {
    Say "This Windows is running inside a virtual machine ($model)." Yellow
    Say "Docker needs 'nested virtualization' switched on by the machine that hosts it:" Yellow
    Say "  - Hyper-V host (PowerShell as admin, VM turned off):"
    Say "      Set-VMProcessor -VMName <name> -ExposeVirtualizationExtensions `$true"
    Say "  - VMware: VM Settings > Processors > 'Virtualize Intel VT-x/EPT or AMD-V/RVI'"
    Say "  - VirtualBox: Settings > System > Processor > 'Enable Nested VT-x/AMD-V'"
    Say "  - Cloud PC / work VM: ask your IT admin to enable nested virtualization."
    Say "Then start the VM again and run setup.cmd."
    exit 21
  }
  Say "Virtualization is switched OFF in this computer's BIOS/UEFI." Yellow
  Say "Windows can't change this - you turn it on once in the firmware settings:" Yellow
  Say ""
  Say " 1. Restart into BIOS/UEFI (this script can do it for you - see below), or"
  Say "    Settings > System > Recovery > Advanced startup > Restart now >"
  Say "    Troubleshoot > Advanced options > UEFI Firmware Settings > Restart."
  Say "    (Or tap the key while it boots: Dell F2 | HP Esc then F10 | Lenovo F1/F2"
  Say "     | ASUS/MSI F2 or Del | Acer F2 | Surface: hold Volume Up + Power.)"
  Say " 2. Find the setting - usually under Advanced, CPU Configuration or Security:"
  Say "    Intel: 'Intel Virtualization Technology' / 'VT-x' / 'Intel VT'"
  Say "    AMD:   'SVM Mode' / 'AMD-V'"
  Say " 3. Set it to Enabled, then Save & Exit (often F10)."
  Say " 4. Back in Windows, run fix-docker.cmd again to finish the Windows side."
  Say ""
  Say "Work or school laptop with a BIOS password? Your IT admin has to enable it." DarkGray
  if (-not $CheckOnly) {
    $ans = Read-Host "  Restart straight into BIOS/UEFI settings now? Save your work first. [y/N]"
    if ($ans -match '^[Yy]') {
      # /fw = boot into firmware setup (UEFI PCs). Needs admin, so Windows will ask.
      $p = Start-Process shutdown.exe -Verb RunAs -ArgumentList "/r /fw /t 10" -PassThru -Wait -ErrorAction SilentlyContinue
      if ($p -and $p.ExitCode -eq 0) { Say "Restarting into BIOS/UEFI in 10 seconds..." Cyan }
      else { Say "Couldn't reboot into firmware automatically (older BIOS?). Use the key from step 1." Yellow }
    }
  }
  exit 20
}

# ---- Case 2: everything already fine ----
if (-not $needsFix) {
  Say "Virtualization looks good." Green
  Say "If Docker Desktop still complains: open it > Settings > General >" DarkGray
  Say "tick 'Use the WSL 2 based engine' > Apply & restart." DarkGray
  exit 0
}

# ---- Case 3: Windows side needs switching on (we can do this) ----
if ($repairWsl) {
  Say "Virtualization is enabled, but Docker still can't use it." Yellow
  Say "Installing/repairing WSL with 'wsl --install' usually fixes this." Yellow
} else {
  Say "Your CPU supports virtualization, but Windows isn't set up to use it yet." Yellow
  Say "Installing WSL with 'wsl --install' fixes this." Yellow
}
if ($CheckOnly) {
  Say "Run fix-docker.cmd to fix this automatically (needs admin + a restart)." Cyan
  exit 1
}
$ans = Read-Host "  Run 'wsl --install' now? Windows will ask for admin permission, then you restart. [Y/n]"
if ($ans -match '^[Nn]') {
  Say "No changes made. Manual steps are in the README: 'Virtualization support not detected'."
  exit 1
}
$p = Start-Process powershell.exe -Verb RunAs -Wait -PassThru -ErrorAction SilentlyContinue `
  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated"
if (-not $p) { Say "Admin permission was declined - nothing changed." Red; exit 1 }
if ($p.ExitCode -ne 10) {
  Say "Some fixes failed (exit $($p.ExitCode)). Try the manual steps in the README." Red
  exit 1
}
Say "Done! Windows needs a restart to turn virtualization on." Green
$ans = Read-Host "  Restart now? Save your work first. [y/N]"
if ($ans -match '^[Yy]') { shutdown.exe /r /t 10; Say "Restarting in 10 seconds..." Cyan }
Say "After the restart: open Docker Desktop, wait for 'Engine running', then run setup.cmd." Cyan
exit 10
