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
  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [system];
      perSystem = {
        config,
        system,
        ...
      }: {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = (with inputs.wine-overlays.packages.${system}; [wine winetricks-compat]) ++ (with pkgs; [winetricks]);
            shellHook = ''
              export VK_INSTANCE_LAYERS="VK_LAYER_WARCRAFT_overlay"
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
