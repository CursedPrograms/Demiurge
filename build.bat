@echo off
setlocal
cd /d "%~dp0"
rem Builds Demiurge: the editor (bin\), dist\Demiurge (portable) and dist\Demiurge-win64.zip.
rem   build.bat              the editor
rem   build.bat templates    also the export templates (what exported games run on), installed for the editor
rem Needs Visual Studio 2022 (C++) and Python 3 with SCons (pip install scons). The first build takes about an hour.
set "JOBS=%NUMBER_OF_PROCESSORS%"
rem the build's own downloads go in bin\build_deps (Godot's scripts put them there under MSYS; not on C:, often full)
set MSYSTEM=MINGW64
python -m SCons --version >nul 2>&1 || ( echo SCons is missing: pip install scons & goto :error )
if not exist "bin\build_deps\accesskit" (
    echo Getting AccessKit, for screen readers, once...
    python misc\scripts\install_accesskit.py || goto :error
)
if not exist "bin\build_deps\agility_sdk" (
    echo Getting the Direct3D 12 SDK, once...
    python misc\scripts\install_d3d12_sdk_windows.py || goto :error
)
python -m SCons platform=windows target=editor production=yes lto=none -j%JOBS% || goto :error
if /i "%~1"=="templates" (
    python -m SCons platform=windows target=template_release production=yes lto=none -j%JOBS% || goto :error
    python -m SCons platform=windows target=template_debug production=yes lto=none -j%JOBS% || goto :error
)
call :package || goto :error
echo Built: dist\Demiurge-win64.zip
rem installed on this PC: this build replaces that copy too
if exist "%LOCALAPPDATA%\Programs\Demiurge\Demiurge.exe" call "%~dp0install.bat" --quiet
exit /b 0

:package
if exist dist\Demiurge rmdir /s /q dist\Demiurge
mkdir dist\Demiurge
copy /y bin\godot.windows.editor.x86_64.exe dist\Demiurge\Demiurge.exe >nul || exit /b 1
if exist bin\godot.windows.editor.x86_64.console.exe copy /y bin\godot.windows.editor.x86_64.console.exe "dist\Demiurge\Demiurge (console).exe" >nul
for %%f in (bin\*.dll) do copy /y "%%f" dist\Demiurge\ >nul
if exist bin\godot.windows.template_release.x86_64.exe (
    mkdir dist\Demiurge\templates
    copy /y bin\godot.windows.template_release.x86_64.exe dist\Demiurge\templates\windows_release_x86_64.exe >nul
    copy /y bin\godot.windows.template_debug.x86_64.exe dist\Demiurge\templates\windows_debug_x86_64.exe >nul
    if exist bin\godot.windows.template_release.x86_64.console.exe copy /y bin\godot.windows.template_release.x86_64.console.exe dist\Demiurge\templates\windows_release_x86_64_console.exe >nul
    if exist bin\godot.windows.template_debug.x86_64.console.exe copy /y bin\godot.windows.template_debug.x86_64.console.exe dist\Demiurge\templates\windows_debug_x86_64_console.exe >nul
    python -c "import version as v; open(r'dist\Demiurge\templates\version.txt','w').write(f'{v.major}.{v.minor}.{v.patch}.{v.status}' if v.patch else f'{v.major}.{v.minor}.{v.status}')"
)
for %%f in (README.md LICENSE.txt COPYRIGHT.txt NOTICE install.bat install.ps1 install.sh) do if exist %%f copy /y %%f dist\Demiurge\ >nul
if exist dist\Demiurge-win64.zip del dist\Demiurge-win64.zip
"%SystemRoot%\System32\tar.exe" -a -c -f dist\Demiurge-win64.zip -C dist Demiurge || exit /b 1
exit /b 0

:error
echo Build failed, see above.
pause
exit /b 1
