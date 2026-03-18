{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bs-manager
    slimevr
    prismlauncher
    protonup-qt
    wayvr
    unityhub
  ];
}
