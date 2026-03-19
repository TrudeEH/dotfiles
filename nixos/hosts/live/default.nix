{ lib, ... }:

{
  imports = [
    ../../flakes/memory-optimizations/profiles/low.nix
  ];

  users.users.trude.initialHashedPassword = lib.mkForce "";
  services.getty.autologinUser = lib.mkForce "trude";
  services.displayManager.autoLogin = {
    enable = true;
    user = "trude";
  };

  home-manager.users.trude.home.file."dotfiles" = {
    source = ../../..;
    recursive = true;
  };

  networking.hostName = "TrudeLiveCD";
}
