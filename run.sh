#!/bin/sh

set -eu

REPO="clemenscodes/warcraft-vulkan-overlay"
RELEASE="2.0.4.23452"

LAYER_JSON="VkLayer_warcraft_overlay.json"
LAYER_SO="libVkLayer_warcraft_overlay.so"
LAYER_NAME="VK_LAYER_WARCRAFT_overlay"

WINEPATH="$HOME/Games"
WINEPREFIX="$WINEPATH/W3Champions"
W3="$WINEPREFIX/drive_c/Program Files (x86)/Warcraft III/_retail_/x86_64/Warcraft III.exe"
W3C="$WINEPREFIX/drive_c/Program Files/W3Champions/W3Champions.bat"

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

VULKAN_LAYER_DIR="$XDG_DATA_HOME/vulkan/explicit_layer.d"
VULKAN_LIB_DIR="$XDG_DATA_HOME/vulkan/layers"

CACHE_DIR="$XDG_CACHE_HOME/warcraft-vk-overlay"

BASE_URL="https://github.com/$REPO/releases/download/$RELEASE"
JSON_URL="$BASE_URL/$LAYER_JSON"
SO_URL="$BASE_URL/$LAYER_SO"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: Required dependency not found: $1" >&2
    exit 1
  }
}

download() {
  url="$1"
  out="$2"

  if [ ! -f "$out" ]; then
    echo "Downloading $(basename "$out")..."
    curl -L --fail --show-error "$url" -o "$out"
  else
    echo "$(basename "$out") already present in cache."
  fi
}

echo "Checking dependencies..."
need curl
need wine
echo "All required dependencies are available."
echo

echo "Preparing directories..."
mkdir -p \
  "$VULKAN_LAYER_DIR" \
  "$VULKAN_LIB_DIR" \
  "$CACHE_DIR"
echo "Directories ready."
echo

echo "Fetching Warcraft Vulkan Overlay assets (release $RELEASE)..."
download "$JSON_URL" "$CACHE_DIR/$LAYER_JSON"
download "$SO_URL"   "$CACHE_DIR/$LAYER_SO"
echo "Assets ready."
echo

echo "Installing Vulkan layer files..."
install -m 644 "$CACHE_DIR/$LAYER_JSON" "$VULKAN_LAYER_DIR/$LAYER_JSON"
install -m 755 "$CACHE_DIR/$LAYER_SO"   "$VULKAN_LIB_DIR/$LAYER_SO"

if [ ! -f "$VULKAN_LAYER_DIR/$LAYER_JSON" ]; then
  echo "Error: Vulkan layer manifest was not installed correctly." >&2
  exit 1
fi

if [ ! -f "$VULKAN_LIB_DIR/$LAYER_SO" ]; then
  echo "Error: Vulkan layer library was not installed correctly." >&2
  exit 1
fi

echo "Vulkan layer installed successfully."
echo

echo "Configuring runtime environment..."
export VK_INSTANCE_LAYERS="$LAYER_NAME"
export VK_LOADER_DEBUG="none"
export DXVK_LOG_LEVEL="none"
export WINEDEBUG="-all"
export WINEPREFIX
export LD_LIBRARY_PATH="$VULKAN_LIB_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
echo "Environment configured."
echo

if [ "${1:-}" = "w3c" ]; then
  echo "Launching Warcraft III via W3Champions..."
  wine "$W3C"
else
  echo "Launching Warcraft III (Retail)..."
  wine "$W3"
fi

