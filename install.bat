@echo off
setlocal
cd /d "%~dp0"
rem Installs Demiurge for this user: %LOCALAPPDATA%\Programs\Demiurge, with Start menu and Desktop shortcuts.
rem Its export templates (when the build has them) go where the editor looks: %APPDATA%\Demiurge\export_templates.
rem Run build.bat first (or unzip a release and run this beside it).
set "SRC=dist\Demiurge"
if exist "Demiurge.exe" set "SRC=."
if not exist "%SRC%\Demiurge.exe" ( echo Build it first: build.bat & exit /b 1 )
tasklist /fi "imagename eq Demiurge.exe" | find /i "Demiurge.exe" >nul
if not errorlevel 1 ( echo Demiurge is open: close it and run this again. & exit /b 1 )
set "INST=%LOCALAPPDATA%\Programs\Demiurge"
if not exist "%INST%" mkdir "%INST%"
xcopy /e /i /q /y "%SRC%\*" "%INST%\" >nul || ( echo Couldn't copy to %INST% & exit /b 1 )
if exist "%SRC%\templates\version.txt" (
    set /p TV=<"%SRC%\templates\version.txt"
    call set "TDIR=%APPDATA%\Demiurge\export_templates\%%TV%%"
    call xcopy /e /i /q /y "%SRC%\templates\*" "%%TDIR%%\" >nul
)
powershell -NoProfile -Command "$s=New-Object -ComObject WScript.Shell; foreach($d in @([Environment]::GetFolderPath('Programs'),[Environment]::GetFolderPath('Desktop'))){ $l=$s.CreateShortcut((Join-Path $d 'Demiurge.lnk')); $l.TargetPath='%INST%\Demiurge.exe'; $l.WorkingDirectory='%INST%'; $l.IconLocation='%INST%\Demiurge.exe,0'; $l.Description='Demiurge: the Atelier game engine'; $l.Save() }"
echo Installed: %INST%
if /i not "%~1"=="--quiet" echo Start it from the Start menu or the Desktop.
exit /b 0
