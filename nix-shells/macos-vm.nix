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
    quickget macos sonoma
    quickemu --vm macos-sonoma.conf
  '';
}
