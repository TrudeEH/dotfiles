#!/bin/bash

# Dependencies
export NIXPKGS_ALLOW_UNFREE=1
if [ $(pwd) != "$HOME/dotfiles" ]; then
   cd $HOME
   git clone https://github.com/TrudeEH/dotfiles --depth 1
   cd dotfiles
fi

if ! nix --version &>/dev/null; then
   echo "[E] Nix not found."
   echo "[+] Installing the Nix package manager..."
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   echo "[I] Installed Nix."
fi

echo
echo "####################"
echo "# Trude's Dotfiles #"
echo "####################"
echo
echo "1) Set up Generic System"
echo "2) Set up NixOS"
echo "3) Set up macOS"
echo
read -p "> " main_menu

case $main_menu in
   1)
      # Install Home-manager
      nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
      nix-channel --update
      mkdir -p $HOME/.pre-nix-backup/
      mv $HOME/.bashrc $HOME/.profile $HOME/.pre-nix-backup/
      nix-shell '<home-manager>' -A install

      # Apply config
      mkdir -p $HOME/.config/home-manager
      rm $HOME/.config/home-manager/home.nix
      cp ./nix/home.nix $HOME/.config/home-manager/home.nix

      home-manager switch -b backup
      ;;
   2)
      sudo cp -rf ./nix/nixos/* /etc/nixos/
      sudo cp -f ./nix/home.nix /etc/nixos/
      sudo nixos-rebuild switch --flake /etc/nixos#default
      ;;
   3)
      mkdir -p ~/.config/nix-darwin/
      cp -rf ./nix/macOS/* ~/.config/nix-darwin/
      cp -f ./nix/home.nix ~/.config/nix-darwin/

      if [[ $(uname -m) == "x86_64" ]]; then
         echo "Intel mac detected."
         nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.config/nix-darwin#x86
      else
         echo "Apple silicon detected."
         nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.config/nix-darwin#default
      fi
      ;;
   *)
      echo "Invalid option selected."
      return 1
      ;;
esac
