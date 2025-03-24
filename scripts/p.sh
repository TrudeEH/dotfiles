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
      nix-collect-garbage --delete-older-than 7d
      if command -v nixos-rebuild >/dev/null 2>&1; then
        sudo nix-channel --update
        sudo nixos-rebuild switch
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

  checkP() {
    app_name=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    app_name=$(echo "$app_name" | tr " " -)
    # Some package names are different from the command name
    case "$app_name" in
    neovim)
      commandName="nvim"
      ;;
    python)
      commandName="python3"
      ;;
    nodejs)
      commandName="node"
      ;;
    docker-compose)
      commandName="docker compose"
      ;;
    pip)
      commandName="pip3"
      ;;
    *)
      commandName="$app_name"
      ;;
    esac

    if [[ ${packageManagers[@]} =~ "flatpak" ]]; then
      flatpak_apps=$(flatpak list --columns=application)
      echo $flatpak_apps | grep -iq $app_name
      flatpak_success=$?
      if [[ $flatpak_success == 0 ]]; then
        printf "%b\n" "${GREEN}${BOLD}Flatpak:${ENDCOLOR}${GREEN} $(echo "$flatpak_apps" | tr ' ' '\n' | grep -i "$app_name")${ENDCOLOR}"
      fi
    fi

    which "$commandName" &>/dev/null
    distro_success=$?
    if [[ $distro_success == 0 ]]; then
      printf "%b\n" "${GREEN}${BOLD}Distro:${ENDCOLOR}${GREEN} $app_name is installed.${ENDCOLOR}"
    fi

    if [[ $flatpak_success != 0 && $distro_success != 0 ]]; then
      printf "%b\n" "${YELLOW}$app_name not installed.${ENDCOLOR}"
      return 1
    fi
  }

  installP() {
    checkP $1
    if [[ $? != 1 ]]; then
      printf "%b\n" "${GREEN}$1 is already installed.${ENDCOLOR}"
      return 0
    fi
    if [[ ${packageManagers[@]} =~ "nix" ]]; then
      printf "%b\n" "${YELLOW}Attempting nix install...${ENDCOLOR}"
      nix-env -iA nixpkgs.$1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "brew" ]]; then
      printf "%b\n" "${YELLOW}Attempting brew install...${ENDCOLOR}"
      brew install $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "apt" ]]; then
      printf "%b\n" "${YELLOW}Attempting apt install...${ENDCOLOR}"
      sudo apt install $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "paru" ]]; then
      printf "%b\n" "${YELLOW}Attempting paru install...${ENDCOLOR}"
      paru -Sy $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "pacman" ]]; then
      printf "%b\n" "${YELLOW}Attempting pacman install...${ENDCOLOR}"
      sudo pacman -Sy $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "dnf" ]]; then
      printf "%b\n" "${YELLOW}Attempting dnf install...${ENDCOLOR}"
      sudo dnf install $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "flatpak" ]]; then
      printf "%b\n" "${YELLOW}Attempting flatpak install...${ENDCOLOR}"
      flatpak install $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    printf "%b\n" "${RED}ERROR - $1 not found.${ENDCOLOR}"
    return 1
  }

  removeP() {
    checkP $1
    if [[ $? != 0 ]]; then
      printf "%b\n" "${YELLOW}$1 is not installed.${ENDCOLOR}"
      return 0
    fi
    if [[ ${packageManagers[@]} =~ "flatpak" ]]; then
      printf "%b\n" "${YELLOW}Attempting flatpak uninstall...${ENDCOLOR}"
      flatpak uninstall $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "nix" ]]; then
      printf "%b\n" "${YELLOW}Attempting nix uninstall...${ENDCOLOR}"
      nix-env --uninstall $1
    fi
    if [[ ${packageManagers[@]} =~ "brew" ]]; then
      printf "%b\n" "${YELLOW}Attempting brew uninstall...${ENDCOLOR}"
      brew uninstall $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "apt" ]]; then
      printf "%b\n" "${YELLOW}Attempting apt uninstall...${ENDCOLOR}"
      sudo apt remove $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "pacman" ]]; then
      printf "%b\n" "${YELLOW}Attempting pacman uninstall...${ENDCOLOR}"
      sudo pacman -Rs $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "dnf" ]]; then
      printf "%b\n" "${YELLOW}Attempting dnf uninstall...${ENDCOLOR}"
      sudo dnf remove $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    printf "%b\n" "${RED}ERROR - Failed to uninstall $1.${ENDCOLOR}"
    return 1
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
  else
    printf "%b\n" "${YELLOW}${UNDERLINE}[i] Usage:${ENDCOLOR}"
    printf "%b\n" "p (u)       ${FAINT}- update os${ENDCOLOR}"
    printf "%b\n" "p i package ${FAINT}- install package${ENDCOLOR}"
    printf "%b\n" "p r package ${FAINT}- remove package${ENDCOLOR}"
    printf "%b\n" "p c package ${FAINT}- check if package is installed${ENDCOLOR}"
    printf "%b\n" "${FAINT}Supported package managers: flatpak, nix, brew, apt, paru, pacman, dnf${ENDCOLOR}"
    return 1
  fi
)
