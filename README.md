# Warcraft Vulkan Overlay

This repository provides a Vulkan overlay layer for Warcraft III, designed to run under Wine with DXVK.
It includes a prebuilt Vulkan layer shared library, its corresponding Vulkan manifest, and a convenience
launcher script.

The overlay is installed per user and does not require root privileges or system-wide Vulkan changes.

## Contents

- Vulkan Layer
  - libVkLayer_warcraft_overlay.so
  - VkLayer_warcraft_overlay.json
- Launcher Script
  - run.sh – installs the Vulkan layer locally (if needed) and launches Warcraft III

## Requirements

The following requirements are mandatory:

- Linux (x86_64)
- Vulkan-capable GPU and drivers
- Wine **10.16 or newer**
- DXVK **developer / CI build newer than 2.7.1**
- curl (for downloading the layer files from GitHub releases)

## Important Notes on Wine and DXVK Versions

### Wine

Wine **10.16 or newer** is required.

This version introduces proper support for Vulkan shared resources, which are necessary for the
modern Warcraft III WebUI. The WebUI is based on Electron and relies on shared GPU resources between
processes. Older Wine versions do not implement this, causing the infamous getting stuck at lion doors error.

### DXVK

The latest official DXVK release (2.7.1 at the time of writing) is **not sufficient**.

A newer DXVK build is required, either:

- A locally compiled DXVK from the upstream repository, or
- A prebuilt developer / CI artifact from the DXVK GitHub Actions

These newer builds include fixes required for Warcraft III’s current rendering and WebUI pipeline.

Using an outdated DXVK version will result in getting stuck at the lion doors after launching the game.

## What run.sh does

When executed, run.sh performs the following steps:

1. Downloads the required Vulkan layer assets from the GitHub release (if not already cached)
2. Installs the Vulkan layer into standard XDG user locations:
   - `~/.local/share/vulkan/explicit_layer.d`
   - `~/.local/share/vulkan/layers`
3. Configures the required environment variables for Vulkan, DXVK, and Wine
4. Launches Warcraft III using Wine

No system-wide Vulkan configuration is modified.

The script is already marked as executable in the repository.

## Usage

From the project root, simply run:

```sh
./run.sh
```

This launches Warcraft III (Retail).

To launch W3Champions instead:

```sh
./run.sh w3c
```

## Configuration

The script assumes the following Wine prefix layout:

`~/Games/W3Champions/`

If your Wine setup differs, adjust the following variables near the top of run.sh:

- WINEPATH
- WINEPREFIX
- W3
- W3C

## Notes

- The Vulkan layer is enabled explicitly using `VK_INSTANCE_LAYERS`
- The script is safe to run multiple times
- Downloaded assets are cached under `~/.cache/warcraft-vk-overlay`
- No root privileges are required

## Troubleshooting

To enable Vulkan loader or DXVK diagnostics, edit run.sh and temporarily set:

```sh
VK_LOADER_DEBUG=all
DXVK_LOG_LEVEL=info
```

This will print detailed Vulkan loader and DXVK output to the terminal.

If you have issues installing Warcraft III or W3Champions, please see the dedicated [guide](https://github.com/clemenscodes/W3ChampionsOnLinux).
