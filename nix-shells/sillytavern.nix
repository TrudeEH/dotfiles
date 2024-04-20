# SillyTavern - Ai/LLMs WebUI
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/master";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    nodejs
    nodePackages.typescript-language-server
  ];

  # Startup command
  shellHook = ''
    ./start.sh
  '';
}
