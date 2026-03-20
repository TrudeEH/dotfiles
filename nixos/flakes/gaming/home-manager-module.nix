{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Flatscreen
    prismlauncher

    # VR
    bs-manager
    slimevr
    protonup-qt
    wayvr
    vrcx

    # Avatar Creation
    alcom
    unityhub
  ];
}
