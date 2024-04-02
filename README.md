# Trude's Dotfiles

This repository hosts my personal dotfiles.
The install script works on Linux and macOS.

The configuration is done through home-manager.
If you would like to use this repository, I recommend forking it and editing home.nix to your liking.

## Install
```sh
curl -L https://raw.githubusercontent.com/TrudeEH/dotfiles/main/install.sh | bash
```

## Dependencies
- Nix (installed automatically)

## Custom commands
- `extract` Extract compressed files
- `update` Update Nix and the OS.
- `reload` Rebuild the config after changing it.

## Scripts
- `archinstall` Install Arch Linux from the liveCD.
```sh
curl -L https://raw.githubusercontent.com/TrudeEH/dotfiles/main/scripts/archinstall.sh | bash
```

## Supported distros
- Debian
- Fedora Workstation
- Arch Linux

## Tested on
- macOS 14
- Debian Bookworm
- Fedora Worstation 39
- Ubuntu 23.10
- Arch Linux (as of last commit)
