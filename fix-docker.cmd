@echo off
REM ==========================================================================
REM  Fixes Docker Desktop's "Virtualization support not detected" on Windows.
REM  Double-click this file, or run it from Command Prompt.
REM ==========================================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\windows\docker-doctor.ps1"
set EXITCODE=%ERRORLEVEL%
echo.
pause
exit /b %EXITCODE%
