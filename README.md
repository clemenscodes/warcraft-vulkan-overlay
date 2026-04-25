# Warcraft III Vulkan Overlay

An in-game HUD for Warcraft III: Reforged on Linux. Shows hero stats,
abilities, items, control groups, production queues, and more. No game
files are modified and the game cannot detect it.

![Overlay during a match](assets/images/overlay.png)

## What it shows

All panels are on by default and can be turned off individually:

- **Map**: current map name and game time.
- **Teams**: every player's race, color, APM, and resource counts.
- **Hero level**: XP bar and level for each of your heroes.
- **Hero abilities**: ability icons with current cooldowns and levels.
- **Hero inventory**: the six inventory slots with item icons and charges.
- **Upgrades**: completed and in-progress upgrades per player.
- **Control groups**: your nine control groups with per-group unit icons and counts.
- **Units**: selected and idle worker counts.
- **Queues**: every production building's queue, with progress.

## Before you start

The overlay runs on top of Warcraft III. You need the game working on
Linux first. If you have not done that yet, follow the
[W3Champions on Linux guide](https://github.com/clemenscodes/W3ChampionsOnLinux)
and come back once the game launches.

## Step 1: Install

Open a terminal, then run:

```sh
git clone https://github.com/clemenscodes/warcraft-vulkan-overlay
cd warcraft-vulkan-overlay
./install.sh
```

The script downloads the overlay and sets it up for you. You
should see this at the end:

```
Installation complete.
```

If you see any errors, jump to the Troubleshooting section.

## Step 2: Tell your launcher to load the overlay

The overlay does not turn itself on automatically. You have to add
`WARCRAFT_OVERLAY_ENABLE=1` to whatever you use to start the game.
Think of it as a switch you flip before launching. Without it, the
overlay is installed but stays invisible.

### If you launch from a terminal

You probably have a command like this:

```sh
wine "$HOME/Games/W3Champions/drive_c/Program Files/W3Champions/W3Champions.exe"
```

Just add `WARCRAFT_OVERLAY_ENABLE=1` at the very beginning:

```sh
WARCRAFT_OVERLAY_ENABLE=1 wine "$HOME/Games/W3Champions/drive_c/Program Files/W3Champions/W3Champions.exe"
```

That is all. Launch the game with that command and the overlay will appear.

### If you use Lutris

1. Right-click the game in Lutris and choose Configure.
2. Go to System options.
3. Scroll down to Environment variables.
4. Click the plus button and add a new entry:
   - Key: `WARCRAFT_OVERLAY_ENABLE`
   - Value: `1`
5. Save and launch the game as usual.

## Turning panels on or off

After the overlay has run once, it creates a settings file at:

```
/home/YOUR_USERNAME/.config/warcraft-overlay/config.toml
```

Replace `YOUR_USERNAME` with your actual username. Open that file in
any text editor and set any panel to `false` to hide it:

```toml
control_groups  = true
hero_abilities  = true
hero_inventory  = true
hero_level      = true
map             = true
queues          = true
teams           = true
units           = true
upgrades        = true
```

You do not need to restart the game. The overlay notices the change
within a few seconds and updates live.

You can also control each panel by adding more entries in the
environment variables section of your launcher (same place as
`WARCRAFT_OVERLAY_ENABLE`). Set the value to `0` to hide a panel, `1`
to show it. These take priority over the settings file.

| Panel          | Key to add                        |
| -------------- | --------------------------------- |
| Control groups | `WARCRAFT_OVERLAY_CONTROL_GROUPS` |
| Hero abilities | `WARCRAFT_OVERLAY_HERO_ABILITIES` |
| Hero inventory | `WARCRAFT_OVERLAY_HERO_INVENTORY` |
| Hero level     | `WARCRAFT_OVERLAY_HERO_LEVEL`     |
| Map            | `WARCRAFT_OVERLAY_MAP`            |
| Queues         | `WARCRAFT_OVERLAY_QUEUES`         |
| Teams          | `WARCRAFT_OVERLAY_TEAMS`          |
| Units          | `WARCRAFT_OVERLAY_UNITS`          |
| Upgrades       | `WARCRAFT_OVERLAY_UPGRADES`       |

## Streaming with OBS

There are two ways to capture the game in OBS.

### Screen capture (simplest)

Use a Screen Capture or Window Capture source in OBS. Since the overlay
is drawn directly onto the game window, it shows up in the capture
automatically. Nothing extra to configure.

### Swapchain capture (better performance, lower latency)

This requires the [obs-vkcapture plugin](https://github.com/nowrep/obs-vkcapture).
Install it first, then add a Game Capture source in OBS.

The plugin captures the game directly from the GPU. For the HUD to show
up in the capture, the overlay must draw into the frame before the plugin
takes it. This works automatically as long as the overlay is running as
an implicit Vulkan layer, which `install.sh` sets up correctly.

Add `OBS_VKCAPTURE=1` to the game launch command alongside
`WARCRAFT_OVERLAY_ENABLE=1`:

```sh
WARCRAFT_OVERLAY_ENABLE=1 OBS_VKCAPTURE=1 wine "$HOME/Games/W3Champions/drive_c/Program Files/W3Champions/W3Champions.exe"
```

In Lutris, add both variables under the game's environment variables the
same way you added `WARCRAFT_OVERLAY_ENABLE`.

If you did a manual install and registered the layer as an explicit layer
instead of implicit, the plugin captures the frame before the overlay
draws and the HUD will not appear in the recording. Redo the install with
`install.sh` to fix this.

## Troubleshooting

### The overlay does not appear at all

The most common cause is that `WARCRAFT_OVERLAY_ENABLE=1` was not
passed to the game. Double-check that you added it to the right place:

- Terminal/Script: it has to be at the very beginning of the wine command, before the word `wine`.
- Lutris: it has to be in the game's own System options under Environment variables, not somewhere else in Lutris.

If you are sure it is set, check that the install actually worked:

```sh
ls ~/.local/share/vulkan/implicit_layer.d/
```

You should see the files: `VkLayer_warcraft_overlay_linux.json` and
`libVkLayer_warcraft_overlay.so`. If they are missing, run
`./install.sh` again from the cloned folder.

### The overlay does not appear and the game version recently changed

The overlay checks the running game version and refuses to render if it
does not match the version it was built for. If Blizzard shipped a patch
and the overlay went dark, you are on a newer game version than the
current release supports.

Wait for a new release, or download an older release from the
[releases page](https://github.com/clemenscodes/warcraft-vulkan-overlay/releases)
that matches your game version and install it manually:

```sh
LAYER_DIR="$HOME/.local/share/vulkan/implicit_layer.d"
install -m 644 VkLayer_warcraft_overlay_linux.json "$LAYER_DIR/"
install -m 755 libVkLayer_warcraft_overlay.so      "$LAYER_DIR/"
```

### The game gets stuck at the lion doors

The loading screen never progresses past the lion doors animation. This
is not caused by the overlay. It is a Wine or DXVK version problem. See
the [W3Champions on Linux guide](https://github.com/clemenscodes/W3ChampionsOnLinux).

### OBS does not capture the HUD

If you are using screen capture, the overlay should just appear. Make
sure the overlay is actually visible in the game first.

If you are using swapchain capture, `OBS_VKCAPTURE=1` has to be set on
the game launch command, not on OBS. See the Streaming with OBS section
above.

Also make sure the overlay was installed with `install.sh`. Swapchain
capture requires the overlay to be an implicit Vulkan layer. If you
registered it as an explicit layer manually, OBS takes the frame before
the overlay draws and the HUD will not be in the capture.

### Something still does not work

Run the game from a terminal with extra logging turned on and look for
any error messages:

```sh
WARCRAFT_OVERLAY_ENABLE=1 VK_LOADER_DEBUG=error DXVK_LOG_LEVEL=warn wine "$HOME/Games/W3Champions/drive_c/Program Files/W3Champions/W3Champions.exe"
```

Paste the output into a [GitHub issue](https://github.com/clemenscodes/warcraft-vulkan-overlay/issues).

## Versioning

Each release targets exactly one Warcraft III version. The release tag is
the game version it was built for, for example `2.0.4.23745`. When
Blizzard ships a patch, a new build goes out under the new version tag
once offsets are updated.

## Advanced

This section is for people who use Nix or want to manage the installation
manually. If `install.sh` worked for you, you do not need any of this.

### Windows (experimental)

Windows is not confirmed working. The overlay only renders when Warcraft
III presents through Vulkan, which on Windows requires running the game
through DXVK instead of its native Direct3D path. That setup has not been
verified yet. The Windows binary (`VkLayer_warcraft_overlay.dll`) is
shipped anyway so it is ready when that gets sorted out. If you get it
working, please open an issue with the steps.

### Nix

#### Home-manager module (recommended for NixOS)

The flake ships a home-manager module that installs the layer as symlinks
into `~/.local/share/vulkan/implicit_layer.d/`. Add it to your flake
inputs and enable it in your home configuration:

```nix
# flake.nix inputs
inputs.warcraft-vulkan-overlay.url = "github:clemenscodes/warcraft-vulkan-overlay";

# home.nix (or wherever your home-manager config lives)
imports = [ inputs.warcraft-vulkan-overlay.homeManagerModules.default ];
warcraft.overlay.enable = true;
```

After rebuilding your home configuration, set `WARCRAFT_OVERLAY_ENABLE=1`
when launching the game as described in Step 2 above.

#### Dev shell

The flake also exposes a dev shell that pulls in Wine, Winetricks, and the
overlay, and sets all required environment variables including
`WARCRAFT_OVERLAY_ENABLE=1`. Run it from the repo root:

```sh
nix develop github:clemenscodes/warcraft-vulkan-overlay
wine "$W3C"
```

`$W3C` is pre-set to the W3Champions launcher path inside the default
Wine prefix (`$HOME/Games/W3Champions`). Adjust if your prefix is
elsewhere.

### Manual install

Download `libVkLayer_warcraft_overlay.so` and
`VkLayer_warcraft_overlay_linux.json` from the latest
[release](https://github.com/clemenscodes/warcraft-vulkan-overlay/releases).

```sh
LAYER_DIR="$HOME/.local/share/vulkan/implicit_layer.d"
mkdir -p "$LAYER_DIR"
install -m 644 VkLayer_warcraft_overlay_linux.json "$LAYER_DIR/"
install -m 755 libVkLayer_warcraft_overlay.so      "$LAYER_DIR/"
```

Then set `WARCRAFT_OVERLAY_ENABLE=1` when launching the game.
