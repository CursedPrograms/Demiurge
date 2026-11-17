#!/usr/bin/env bash
# Installs Demiurge. On Windows (Git Bash) this runs install.bat; on Linux it copies the editor to ~/.local/bin/demiurge
# with a menu entry.
set -e
cd "$(dirname "$0")"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) cmd //c install.bat "$@"; exit $? ;;
esac
BIN=bin/godot.linuxbsd.editor.x86_64
[ -f "$BIN" ] || { echo "Build it first: ./build.sh"; exit 1; }
mkdir -p ~/.local/bin ~/.local/share/applications ~/.local/share/icons
install -m 755 "$BIN" ~/.local/bin/demiurge
cp misc/demiurge/logo.png ~/.local/share/icons/demiurge.png
cat > ~/.local/share/applications/demiurge.desktop <<EOF
[Desktop Entry]
Name=Atelier - Demiurge
Comment=The Atelier game engine
Exec=$HOME/.local/bin/demiurge
Icon=$HOME/.local/share/icons/demiurge.png
Terminal=false
Type=Application
Categories=Development;IDE;
EOF
echo "Installed: ~/.local/bin/demiurge"
