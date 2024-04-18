# Rust development.

let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/master";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    # Rust packages
    rustc
    cargo

    # Shell utils
    strace
    wget
    curl
  ];

  shellHook = ''
    echo
    PS1='\n\[\e[2m\][RUST]\[\e[0m\] \[\e[1m\]\w\[\e[0m\] \[\e[3m\]$(git branch --show-current 2>/dev/null)\n\[\e[0m\]\$ '
    echo -e "\e[31m[NIX-SHELL • RUST DEVELOPMENT ENVIRONMENT] \e[0m"
    echo -ne "\e[1mVersion: \e[0m"
    rustc --version
    echo -ne "         "
    cargo --version
  '';
}
