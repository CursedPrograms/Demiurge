#!/usr/bin/env bash
# The C# build of Demiurge, step by step (build.bat calls the same steps on Windows):
# the editor with .NET, its C# glue, the GodotSharp assemblies, then the export templates with .NET.
# Needs the .NET 8 SDK (dotnet) on top of what build.bat needs.
set -e
cd "$(dirname "$0")"
export MSYSTEM=${MSYSTEM:-MINGW64}   # the build's downloads in bin/build_deps
JOBS=$(nproc 2>/dev/null || echo 8)
PY=$(command -v python || command -v python3)   # (the one with SCons: pip install scons)
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) PLAT=windows; EXE=.exe ;; *) PLAT=linuxbsd; EXE= ;; esac
OPTS="production=yes lto=none module_mono_enabled=yes"
$PY -m SCons platform=$PLAT target=editor $OPTS -j$JOBS
ED=bin/godot.$PLAT.editor.x86_64.mono$EXE
$ED --headless --generate-mono-glue modules/mono/glue
$PY modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=$PLAT
if [ "$1" != "editor" ]; then
  $PY -m SCons platform=$PLAT target=template_release $OPTS -j$JOBS
  $PY -m SCons platform=$PLAT target=template_debug $OPTS -j$JOBS
fi
echo "C# build done: $ED, bin/GodotSharp, and the templates"
