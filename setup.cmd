@echo off
REM ==========================================================================
REM  HackAlem / QBERS - Windows setup (Command Prompt or double-click)
REM  Runs setup.ps1 with PowerShell, which ships with every Windows 10/11.
REM ==========================================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*
set EXITCODE=%ERRORLEVEL%
if "%EXITCODE%"=="3" (
  echo.
  echo Almost there - restart Windows, then run setup.cmd again.
  pause
) else if not "%EXITCODE%"=="0" (
  echo.
  echo Setup did not finish. Read the message above, fix it, and run setup.cmd again.
  pause
)
exit /b %EXITCODE%
