{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    wine-overlays = {
      url = "github:clemenscodes/wine-overlays";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (final: prev: { inherit warcraft-vulkan-overlay; }) ];
      };
      warcraft-vulkan-overlay = pkgs.callPackage ./default.nix {
        pname = "warcraft-vulkan-overlay";
        version = "2.0.4.23745";
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.flake-parts.flakeModules.easyOverlay ];
      systems = [ system ];

      flake.homeManagerModules.default =
        { lib, config, ... }:
        let
          cfg = config.warcraft.overlay;
        in
        {
          options.warcraft.overlay = {
            enable = lib.mkEnableOption "Warcraft III Vulkan overlay implicit layer";
          };
          config = lib.mkIf cfg.enable {
            home.file = {
              ".local/share/vulkan/implicit_layer.d/VkLayer_warcraft_overlay_linux.json".source =
                "${warcraft-vulkan-overlay}/share/vulkan/implicit_layer.d/VkLayer_warcraft_overlay_linux.json";
              ".local/share/vulkan/implicit_layer.d/libVkLayer_warcraft_overlay.so".source =
                "${warcraft-vulkan-overlay}/lib/libVkLayer_warcraft_overlay.so";
            };
          };
        };

      perSystem =
        {
          config,
          system,
          ...
        }:
        {
          overlayAttrs = { inherit warcraft-vulkan-overlay; };
          packages = {
            inherit warcraft-vulkan-overlay;
          }
          // {
            default = self.packages.${system}.warcraft-vulkan-overlay;
          };
          devShells = {
            default = pkgs.mkShell {
              buildInputs =
                (with inputs.wine-overlays.packages.${system}; [
                  wine
                  winetricks-compat
                ])
                ++ (with pkgs; [ winetricks ])
                ++ [ warcraft-vulkan-overlay ];
              shellHook = ''
                export WARCRAFT_OVERLAY_ENABLE=1
                export XDG_DATA_DIRS="${warcraft-vulkan-overlay}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
                export VK_LOADER_DEBUG="none"
                export DXVK_LOG_LEVEL="none"
                export WINEDEBUG="-all"
                export WINEPATH="$HOME/Games"
                export WINEPREFIX="$WINEPATH/W3Champions"
                export W3="$WINEPREFIX/drive_c/Program Files (x86)/Warcraft III/_retail_/x86_64/Warcraft III.exe"
                export W3C="$WINEPREFIX/drive_c/Program Files/W3Champions/W3Champions.bat"
              '';
            };
          };
        };
    };
}
