{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Flatscreen
    prismlauncher
    hydralauncher

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
