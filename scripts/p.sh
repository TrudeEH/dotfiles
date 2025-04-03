#! /bin/bash
# Cross-distro package manager UI

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
GRAY="\e[90m"

BOLD="\e[1m"
FAINT="\e[2m"
ITALIC="\e[3m"
UNDERLINE="\e[4m"

ENDCOLOR="\e[0m"

pcheck() {
  local pms=()
  if command -v flatpak >/dev/null 2>&1; then
    pms+=("flatpak")
  fi
  if command -v nix >/dev/null 2>&1; then
    pms+=("nix")
  fi
  if command -v brew >/dev/null 2>&1; then
    pms+=("brew")
  fi
  if command -v apt >/dev/null 2>&1; then
    pms+=("apt")
  elif command -v pacman >/dev/null 2>&1; then
    if command -v paru >/dev/null 2>&1; then
      pms+=("paru")
    fi
    pms+=("pacman")
  elif command -v dnf >/dev/null 2>&1; then
    pms+=("dnf")
  fi
  echo "${pms[@]}"
}

p() (
  trap "echo -e '\n${RED}p interrupted.${NC}'; exit 1" SIGINT SIGTERM
  packageManagers=($(pcheck))

  updateP() {
    if [[ ${packageManagers[@]} =~ "flatpak" ]]; then
      printf "%b\n" "${YELLOW}Updating flatpak...${ENDCOLOR}"
      flatpak update
      flatpak uninstall --unused --delete-data
    fi
    if [[ ${packageManagers[@]} =~ "nix" ]]; then
      printf "%b\n" "${YELLOW}Updating nix...${ENDCOLOR}"
      nix-channel --update
      nix-collect-garbage --delete-older-than 7d &>/dev/null
      if command -v nixos-rebuild >/dev/null 2>&1; then
        sudo nix-channel --update
        printf "${YELLOW}Rebuilding NixOS...${NC}\n"
        sudo nixos-rebuild switch &>/tmp/nixos_rebuild.log || (
          cat /tmp/nixos_rebuild.log | grep --color error && false
        )
      fi
    fi
    if [[ ${packageManagers[@]} =~ "brew" ]]; then
      printf "%b\n" "${YELLOW}Updating brew...${ENDCOLOR}"
      brew update
      brew doctor
      brew upgrade
    fi
    if [[ ${packageManagers[@]} =~ "apt" ]]; then
      printf "%b\n" "${YELLOW}Updating apt...${ENDCOLOR}"
      sudo apt update
      sudo apt upgrade
      sudo apt dist-upgrade
      sudo apt autoremove
      sudo apt autoclean
    elif [[ ${packageManagers[@]} =~ "pacman" ]]; then
      printf "%b\n" "${YELLOW}Updating pacman...${ENDCOLOR}"
      sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
      if [[ ${packageManagers[@]} =~ "paru" ]]; then
        paru -Syu
      else
        sudo pacman -Syu
      fi
      sudo pacman -Rsn $(pacman -Qdtq)
      if [ ! "$(command -v reflector)" ]; then
        printf "%b\n" "${YELLOW}Selecting fastest pacman mirrors...${ENDCOLOR}"
        sudo pacman -Sy --noconfirm reflector rsync curl
        iso=$(curl -4 ifconfig.co/country-iso)
        extra="FR"
        sudo reflector -a 48 -c $iso -c $extra -f 5 -l 30 --verbose --sort rate --save /etc/pacman.d/mirrorlist
      fi
      if [ ! "$(command -v paccache)" ]; then
        sudo pacman -Sy --noconfirm pacman-contrib
      fi
      paccache -rk1
    elif [[ ${packageManagers[@]} =~ "dnf" ]]; then
      printf "%b\n" "${YELLOW}Updating dnf...${ENDCOLOR}"
      sudo dnf upgrade --refresh
      sudo dnf autoremove
    fi
  }

  installP() {
    for pm in "${packageManagers[@]}"; do
      printf "%b\n" "${YELLOW}Attempting ${pm} install...${ENDCOLOR}"
      case "$pm" in
      flatpak)
        flatpak install "$1"
        ;;
      paru)
        paru -Sy "$1"
        ;;
      apt)
        sudo apt install "$1"
        ;;
      pacman)
        sudo pacman -Sy "$1"
        ;;
      dnf)
        sudo dnf install "$1"
        ;;
      brew)
        brew install "$1"
        ;;
      *)
        continue
        ;;
      esac
      if [[ $? == 0 ]]; then
        return 0
      fi
    done
    printf "%b\n" "${RED}ERROR: $1 not found.${ENDCOLOR}"
    return 1
  }

  removeP() {
    for pm in "${packageManagers[@]}"; do
      printf "%b\n" "${YELLOW}Attempting ${pm} uninstall...${ENDCOLOR}"
      case "$pm" in
      flatpak)
        flatpak uninstall "$1"
        ;;
      brew)
        brew uninstall "$1"
        ;;
      apt)
        sudo apt remove "$1"
        ;;
      pacman)
        sudo pacman -Rs "$1"
        ;;
      paru)
        paru -Rns "$1"
        ;;
      dnf)
        sudo dnf remove "$1"
        ;;
      *)
        continue
        ;;
      esac
      if [[ $? == 0 ]]; then
        return 0
      fi
    done
    printf "%b\n" "${RED}ERROR: $1 not found.${ENDCOLOR}"
    return 1
  }

  shellP() {
    if [[ ${packageManagers[@]} =~ "nix" ]]; then
      printf "%b\n" "${YELLOW}Attempting to create nix shell...${ENDCOLOR}"
      nix-shell -p $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
  }

  # If no parameter or u
  printf "%b\n" "${CYAN}Detected package managers: ${MAGENTA}${packageManagers[*]}${ENDCOLOR}"
  if [ -z $1 ] || [ $1 = "u" ]; then
    updateP
    return 0
  elif [ $1 = "i" ]; then # If first parameter is i (install)
    shift
    for package in "$@"; do
      installP $package
    done
  elif [ $1 = "r" ]; then # If first parameter is r (remove)
    shift
    for package in "$@"; do
      removeP $package
    done
  elif [ $1 = "c" ]; then # If first parameter is c (check)
    shift
    for package in "$@"; do
      checkP $package
    done
  elif [ $1 = "s" ]; then # If first parameter is s (shell)
    shift
    shellP $@
  else
    printf "%b\n" "${YELLOW}${UNDERLINE}[i] Usage:${ENDCOLOR}"
    printf "%b\n" "p (u)       ${FAINT}- update os${ENDCOLOR}"
    printf "%b\n" "p i package ${FAINT}- install package${ENDCOLOR}"
    printf "%b\n" "p r package ${FAINT}- remove package${ENDCOLOR}"
    printf "%b\n" "p s packages ${FAINT}- launch a nix shell with the specified packages${ENDCOLOR}"
    printf "%b\n" "${FAINT}Supported package managers: flatpak, nix, brew, apt, paru, pacman, dnf${ENDCOLOR}"
    return 1
  fi
)
