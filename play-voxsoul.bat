@echo off
setlocal
set "ROOT=%~dp0"
set "LUANTI=%ROOT%tools\luanti\luanti-5.16.1-win64"
set "WORLD=%ROOT%games\voxsoul\worlds\demo_interlude"

rem End any leftover Luanti (headless server / crashed client) blocking port 30000
taskkill /F /IM luanti.exe >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":30000"') do (
    taskkill /F /PID %%a >nul 2>&1
)
ping 127.0.0.1 -n 2 >nul

cd /d "%LUANTI%"
start "" "%LUANTI%\bin\luanti.exe" --world "%WORLD%" --gameid voxsoul --go --name Tarnished --logfile "%ROOT%tools\luanti-client.log"
