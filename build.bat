@echo off
setlocal
cd /d "%~dp0"
rem Builds Demiurge with C#: the editor, its C# glue and assemblies (bin\GodotSharp), the export templates (what
rem exported games run on), then dist\Demiurge (portable) and dist\Demiurge-win64.zip.
rem   build.bat           everything
rem   build.bat editor    the editor only (no export templates)
rem Needs Visual Studio 2022 (C++), the .NET 8 SDK and Python 3 with SCons (pip install scons). The first build
rem takes about an hour and a half on 12 threads.
set "JOBS=%NUMBER_OF_PROCESSORS%"
rem the build's own downloads go in bin\build_deps (Godot's scripts put them there under MSYS; not on C:, often full)
set MSYSTEM=MINGW64
set "OPTS=production=yes lto=none module_mono_enabled=yes"
python -m SCons --version >nul 2>&1 || ( echo SCons is missing: pip install scons & goto :error )
dotnet --list-sdks >nul 2>&1 || ( echo The .NET 8 SDK is missing: https://dotnet.microsoft.com/download & goto :error )
if not exist "bin\build_deps\accesskit" (
    echo Getting AccessKit, for screen readers, once...
    python misc\scripts\install_accesskit.py || goto :error
)
if not exist "bin\build_deps\agility_sdk" (
    echo Getting the Direct3D 12 SDK, once...
    python misc\scripts\install_d3d12_sdk_windows.py || goto :error
)
python -m SCons platform=windows target=editor %OPTS% -j%JOBS% || goto :error
bin\godot.windows.editor.x86_64.mono.exe --headless --generate-mono-glue modules\mono\glue || goto :error
python modules\mono\build_scripts\build_assemblies.py --godot-output-dir=bin --godot-platform=windows || goto :error
if /i not "%~1"=="editor" (
    python -m SCons platform=windows target=template_release %OPTS% -j%JOBS% || goto :error
    python -m SCons platform=windows target=template_debug %OPTS% -j%JOBS% || goto :error
)
call :package || goto :error
echo Built: dist\Demiurge-win64.zip
rem installed on this PC: this build replaces that copy too
if exist "%LOCALAPPDATA%\Programs\Demiurge\Demiurge.exe" call "%~dp0install.bat" --quiet
exit /b 0

:package
if exist dist\Demiurge rmdir /s /q dist\Demiurge
mkdir dist\Demiurge
copy /y bin\godot.windows.editor.x86_64.mono.exe dist\Demiurge\Demiurge.exe >nul || exit /b 1
if exist bin\godot.windows.editor.x86_64.mono.console.exe copy /y bin\godot.windows.editor.x86_64.mono.console.exe dist\Demiurge\Demiurge.console.exe >nul
for %%f in (bin\*.dll) do copy /y "%%f" dist\Demiurge\ >nul
rem C#: the editor's own assemblies, beside it
xcopy /e /i /q /y bin\GodotSharp dist\Demiurge\GodotSharp >nul || exit /b 1
if exist bin\godot.windows.template_release.x86_64.mono.exe (
    mkdir dist\Demiurge\templates
    copy /y bin\godot.windows.template_release.x86_64.mono.exe dist\Demiurge\templates\windows_release_x86_64.exe >nul
    copy /y bin\godot.windows.template_debug.x86_64.mono.exe dist\Demiurge\templates\windows_debug_x86_64.exe >nul
    if exist bin\godot.windows.template_release.x86_64.mono.console.exe copy /y bin\godot.windows.template_release.x86_64.mono.console.exe dist\Demiurge\templates\windows_release_x86_64_console.exe >nul
    if exist bin\godot.windows.template_debug.x86_64.mono.console.exe copy /y bin\godot.windows.template_debug.x86_64.mono.console.exe dist\Demiurge\templates\windows_debug_x86_64_console.exe >nul
    rem the folder name the editor looks for: 4.7.2.stable
    python -c "import version as v; open(r'dist\Demiurge\templates\version.txt','w').write((f'{v.major}.{v.minor}.{v.patch}' if v.patch else f'{v.major}.{v.minor}') + f'.{v.status}')"
)
for %%f in (README.md LICENSE.txt COPYRIGHT.txt NOTICE install.bat install.ps1 install.sh) do if exist %%f copy /y %%f dist\Demiurge\ >nul
if exist dist\Demiurge-win64.zip del dist\Demiurge-win64.zip
"%SystemRoot%\System32\tar.exe" -a -c -f dist\Demiurge-win64.zip -C dist Demiurge || exit /b 1
exit /b 0

:error
echo Build failed, see above.
pause
exit /b 1
