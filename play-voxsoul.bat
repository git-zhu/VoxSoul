@echo off
setlocal
set "ROOT=%~dp0"
set "LUANTI=%ROOT%tools\luanti\luanti-5.16.1-win64"
set "WORLD=%ROOT%games\voxsoul\worlds\demo_interlude"
cd /d "%LUANTI%"
start "" "%LUANTI%\bin\luanti.exe" --world "%WORLD%" --gameid voxsoul --go --name Tarnished --logfile "%ROOT%tools\luanti-client.log"
