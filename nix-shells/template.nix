# https://nix.dev/tutorials/declarative-and-reproducible-developer-environments
let
  # nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-23.11";
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/master";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    cowsay
    lolcat
  ];

  # Environment Variables
  GREETING = "Hello, Nix!";

  # Startup command
  shellHook = ''
    echo $GREETING | cowsay | lolcat
  '';
}
