{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Flatscreen
    prismlauncher
    hydralauncher
    (vintagestory.overrideAttrs (_: rec {
      version = "1.21.1";
      src = fetchurl {
        url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
        hash = "sha256-6b0IXzTawRWdm2blOpMAIDqzzv/S7O3c+5k7xOhRFvI=";
      };
    }))

    # VR
    bs-manager
    slimevr
    wayvr
    vrcx

    # Avatar Creation
    p7zip # Unity Hub dependency
    unityhub
    alcom
  ];
}
