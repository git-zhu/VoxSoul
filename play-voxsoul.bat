@echo off
setlocal
set "ROOT=%~dp0"
set "LUANTI=%ROOT%tools\luanti\luanti-5.16.1-win64"
set "WORLD=%ROOT%games\voxsoul\worlds\demo_interlude"

rem Kill stale Luanti server still holding port 30000 (crashed/hung sessions)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":30000" ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
)

cd /d "%LUANTI%"
start "" "%LUANTI%\bin\luanti.exe" --world "%WORLD%" --gameid voxsoul --go --name Tarnished --logfile "%ROOT%tools\luanti-client.log"
