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
    sha256 = "sha256-UFdIpk6dWR1FYpQHkUeRBnn3LUXVDuvN/3cIzK3MNbw=";
  };
  manifest = fetchurl {
    url = "https://github.com/${repo}/releases/download/${version}/${layerJson}";
    sha256 = "sha256-6dIWTyey5hJXLBQCxe9zlVKCtCt00uwCZUF8SpIRVY8=";
  };
in
  stdenv.mkDerivation {
    inherit pname version;

    src = ./.;

    dontUnpack = true;

    nativeBuildInputs = [jq];

    installPhase = ''
      runHook preInstall

      layerDir="$out/share/vulkan/implicit_layer.d"
      mkdir -p "$out/lib" "$layerDir"

      ln -sf ${layer} "$out/lib/${layerSo}"
      jq --arg path "./${layerSo}" '.layers[0].library_path = $path' ${manifest} \
        > "$layerDir/${layerJson}"
      ln -s "../../../lib/${layerSo}" "$layerDir/${layerSo}"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Vulkan overlay layer for Warcraft III (Wine/DXVK)";
      homepage = "https://github.com/${repo}";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  }
