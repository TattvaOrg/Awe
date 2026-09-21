#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_PATH="$SCRIPT_DIR/bin/awe"

echo "─── Installing Awe Desktop Widgets & CLI ───"
chmod +x "$BIN_PATH"
"$BIN_PATH" install

echo ""
echo "Installation complete!"
echo "Run 'awe' in your terminal to launch the rich Settings UI panel."
echo "Run 'awe --help' for CLI commands and daemon management."
