let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    quickemu
  ];

  shellHook = ''
    mkdir -p macos-vm
    cd macos-vm
    if [ ! -d "macos-sonoma" ]; then
      quickget macos sonoma
    fi
    quickemu --vm macos-sonoma.conf
  '';
}
