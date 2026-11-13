#!/usr/bin/env bash
# Builds Demiurge. On Windows (Git Bash) this runs build.bat; on Linux it builds the Linux editor into bin/.
#   ./build.sh            the editor
#   ./build.sh templates  also the export templates
# Linux needs: python3 + scons, a C++ compiler and Godot's usual packages (see README.godot.md for the list).
set -e
cd "$(dirname "$0")"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) cmd //c build.bat "$@"; exit $? ;;
esac
JOBS=$(nproc 2>/dev/null || echo 4)
python3 -m SCons platform=linuxbsd target=editor production=yes lto=none -j"$JOBS"
if [ "$1" = "templates" ]; then
  python3 -m SCons platform=linuxbsd target=template_release production=yes lto=none -j"$JOBS"
  python3 -m SCons platform=linuxbsd target=template_debug production=yes lto=none -j"$JOBS"
fi
echo "Built: bin/godot.linuxbsd.editor.x86_64 (run it as Demiurge, or ./install.sh)"
