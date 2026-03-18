#!/usr/bin/env bash

set -euo pipefail

install_trudeserver() {
  echo 'Installing TrudeServer Config...'
  sudo nixos-rebuild switch --flake "${FLAKE_PATH}#${TRUDESERVER_TARGET}"
  echo 'TrudeServer config restored.'
}

build_live_iso() {
  echo 'Building LiveISO...'
  nix build "./nixos#nixosConfigurations.live.config.system.build.isoImage" --extra-experimental-features nix-command --extra-experimental-features flakes
  echo 'LiveISO build complete.'
}

show_main_menu() {
  local options=("TrudeServer" "LiveISO" "Quit")

  printf 'Select an installation target:\n'
  PS3='Choice: '
  select option in "${options[@]}"; do
    case "${option}" in
      TrudeServer)
        install_trudeserver
        break
        ;;
      LiveISO)
        build_live_iso
        break
        ;;
      Quit)
        printf 'Exiting.\n'
        exit 0
        ;;
      *)
        printf 'Invalid selection. Please choose 1, 2, or 3.\n'
        ;;
    esac
  done
}

show_main_menu
