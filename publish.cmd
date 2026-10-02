@echo off
setlocal
where pwsh >nul 2>nul
if errorlevel 1 (
    echo PowerShell 7 ^(pwsh^) wurde nicht gefunden.
    echo Bitte installieren: https://aka.ms/powershell
    pause
    exit /b 1
)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish.ps1" %*
set "CODE=%ERRORLEVEL%"
echo.
if not "%CODE%"=="0" echo Der Vorgang wurde mit Fehlercode %CODE% beendet.
pause
exit /b %CODE%
