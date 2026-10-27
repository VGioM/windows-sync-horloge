@echo off
:: Relance en administrateur si besoin
net session >nul 2>&1 || (powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs" & exit /b)

:: Service de temps Windows en demarrage automatique
sc config w32time start= auto >nul

:: Regle : resynchroniser l'horloge 1 minute apres chaque demarrage
schtasks /Create /TN "ResyncHorloge" /TR "cmd /c net start w32time & w32tm /resync /force" /SC ONSTART /DELAY 0001:00 /RU SYSTEM /RL HIGHEST /F

pause
