#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_PATH="${SCRIPT_DIR}/nixos"

install_host() {
  local host_name="$1"

  printf 'Installing %s config...\n' "${host_name}"
  sudo nixos-rebuild switch --flake "${FLAKE_PATH}#${host_name}"
  printf '%s config restored.\n' "${host_name}"
}

build_live_iso() {
  printf 'Building LiveISO...\n'
  nix build "${FLAKE_PATH}#nixosConfigurations.live.config.system.build.isoImage" \
    --extra-experimental-features 'nix-command flakes'
  printf 'LiveISO build complete.\n'
}

show_main_menu() {
  local options=("TrudePC" "TrudeLaptop" "LiveISO" "Quit")

  printf 'Select an installation target:\n'
  PS3='Choice: '
  select option in "${options[@]}"; do
    case "${option}" in
      TrudePC|TrudeLaptop)
        install_host "${option}"
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
        printf 'Invalid selection. Please choose 1, 2, 3, or 4.\n'
        ;;
    esac
  done
}

show_main_menu
