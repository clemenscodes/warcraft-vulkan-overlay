#!/bin/sh
# Installs the Warcraft Vulkan overlay layer to the current user's Vulkan layer directory.
# After installation, enable the overlay per-launch by setting WARCRAFT_OVERLAY_ENABLE=1
# in your game launcher or Wine command.

set -eu

REPO="clemenscodes/warcraft-vulkan-overlay"
RELEASE="2.0.4.23745-r4"

LAYER_JSON="VkLayer_warcraft_overlay_linux.json"
LAYER_SO="libVkLayer_warcraft_overlay.so"

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

LAYER_DIR="$XDG_DATA_HOME/vulkan/implicit_layer.d"
CACHE_DIR="$XDG_CACHE_HOME/warcraft-vk-overlay"

BASE_URL="https://github.com/$REPO/releases/download/$RELEASE"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: required command not found: $1" >&2
    exit 1
  }
}

download() {
  url="$1"
  dest="$2"
  if [ ! -f "$dest" ]; then
    echo "Downloading $(basename "$dest")..."
    curl -L --fail --show-error "$url" -o "$dest"
  else
    echo "$(basename "$dest") already cached, skipping download."
  fi
}

echo "Checking dependencies..."
need curl
echo "OK"
echo

echo "Preparing directories..."
mkdir -p "$LAYER_DIR" "$CACHE_DIR"
echo "OK"
echo

echo "Fetching layer assets (release $RELEASE)..."
download "$BASE_URL/$LAYER_JSON" "$CACHE_DIR/$LAYER_JSON"
download "$BASE_URL/$LAYER_SO"   "$CACHE_DIR/$LAYER_SO"
echo "OK"
echo

echo "Installing Vulkan layer to $LAYER_DIR..."
# Normalize library_path to a relative path so the loader finds the .so next to the manifest
sed 's|"library_path": "[^"]*"|"library_path": "./'"$LAYER_SO"'"|' \
  "$CACHE_DIR/$LAYER_JSON" > "$LAYER_DIR/$LAYER_JSON"
install -m 755 "$CACHE_DIR/$LAYER_SO" "$LAYER_DIR/$LAYER_SO"
echo "OK"
echo

echo "Installation complete."
echo
echo "The overlay is an implicit Vulkan layer and activates only when the environment"
echo "variable WARCRAFT_OVERLAY_ENABLE=1 is set for the game process."
echo
echo "Configure your launcher to pass this variable. Examples:"
echo
echo "  Wine directly:"
echo "    WARCRAFT_OVERLAY_ENABLE=1 wine \"${WINEPREFIX:-$HOME/Games/W3Champions}/drive_c/Program Files (x86)/Warcraft III/_retail_/x86_64/Warcraft III.exe\""
echo
echo "  Lutris: Game settings -> System options -> Environment variables"
echo "    Key: WARCRAFT_OVERLAY_ENABLE   Value: 1"
