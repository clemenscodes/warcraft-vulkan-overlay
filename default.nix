{
  lib,
  stdenv,
  fetchurl,
  jq,
  pname,
  version,
}: let
  repo = "clemenscodes/warcraft-vulkan-overlay";
  layerJson = "VkLayer_warcraft_overlay_linux.json";
  layerSo = "libVkLayer_warcraft_overlay.so";
  layer = fetchurl {
    url = "https://github.com/${repo}/releases/download/${version}/${layerSo}";
    sha256 = "sha256-L+ca3CBCeGbg5YKIIaDULQ9FpKsre+/9EPoVTMZ7CN0=";
  };
  manifest = fetchurl {
    url = "https://github.com/${repo}/releases/download/${version}/${layerJson}";
    sha256 = "sha256-J9N4ikOsqFFJsnG4j5D0Q+VRb9G0/1l4cftQNrFUmps=";
  };
in
  stdenv.mkDerivation {
    inherit pname version;

    src = ./.;

    dontUnpack = true;

    nativeBuildInputs = [jq];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib $out/share/vulkan/explicit_layer.d

      ln -sf ${layer} $out/lib/${layerSo}
      jq --arg path "$out/lib/${layerSo}" '.layers[0].library_path = $path' ${manifest} > $out/share/vulkan/explicit_layer.d/${layerJson}

      runHook postInstall
    '';

    meta = with lib; {
      description = "Vulkan overlay layer for Warcraft III (Wine/DXVK)";
      homepage = "https://github.com/${repo}";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  }
