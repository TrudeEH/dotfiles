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
      flatpak update
      flatpak uninstall --unused --delete-data
    fi
    if [[ ${packageManagers[@]} =~ "nix" ]]; then
      nix-channel --update
      sudo nix-channel --update
      nix-collect-garbage --delete-older-than 7d
    fi
    if [[ ${packageManagers[@]} =~ "brew" ]]; then
      brew update
      brew doctor
      brew upgrade
    fi
    if [[ ${packageManagers[@]} =~ "apt" ]]; then
      sudo apt update
      sudo apt upgrade
      sudo apt dist-upgrade
      sudo apt autoremove
      sudo apt autoclean
    elif [[ ${packageManagers[@]} =~ "pacman" ]]; then
      sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
      if [[ ${packageManagers[@]} =~ "paru" ]]; then
        paru -Syu
      else
        sudo pacman -Syu
      fi
      sudo pacman -Rsn $(pacman -Qdtq)
      if [ ! "$(command -v reflector)" ]; then
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
      sudo dnf upgrade --refresh
      sudo dnf autoremove
    fi
  }

  checkP() {
    app_name=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    app_name=$(echo "$app_name" | tr " " -)

    if [[ ${packageManagers[@]} =~ "flatpak" ]]; then
      flatpak_apps=$(flatpak list --columns=application)
      echo $flatpak_apps | grep -iq $app_name
      flatpak_success=$?
      if [[ $flatpak_success == 0 ]]; then
        echo -e "${GREEN}${BOLD}Flatpak:${ENDCOLOR}${GREEN} $(echo $flatpak_apps | tr ' ' '\n' | grep -i $app_name)${ENDCOLOR}"
      fi
    fi
    if [[ ${packageManagers[@]} =~ "nix" ]]; then
      nix_apps=$(nix-env -q)
      echo $nix_apps | grep -iq $app_name
      nix_success=$?
      if [[ $nix_success == 0 ]]; then
        echo -e "${GREEN}${BOLD}Nix:${ENDCOLOR}${GREEN} $(echo $nix_apps | tr ' ' '\n' | grep -i $app_name)${ENDCOLOR}"
      fi
    fi
    if [[ ${packageManagers[@]} =~ "brew" ]]; then
      brew_apps=$(brew list)
      echo $brew_apps | grep -iq $app_name
      brew_success=$?
      if [[ $brew_success == 0 ]]; then
        echo -e "${GREEN}${BOLD}Brew:${ENDCOLOR}${GREEN} $(echo $brew_apps | tr ' ' '\n' | grep -i $app_name)${ENDCOLOR}"
      fi
    fi
    if [[ ${packageManagers[@]} =~ "apt" ]]; then
      distro_apps=$(dpkg-query -l | grep '^ii' | awk '{print $2}')
    elif [[ ${packageManagers[@]} =~ "pacman" ]]; then
      distro_apps=$(pacman -Q)
    elif [[ ${packageManagers[@]} =~ "dnf" ]]; then
      distro_apps=$(dnf list)
    fi

    echo $distro_apps | grep -Eiq "(^|\s)$app_name($|\s)"
    distro_success=$?
    if [[ $distro_success == 0 ]]; then
      echo -e "${GREEN}${BOLD}Distro:${ENDCOLOR}${GREEN} $(echo $distro_apps | tr ' ' '\n' | grep -Ei "(^|\s)$app_name($|\s)")${ENDCOLOR}"
    fi

    if [[ $flatpak_success != 0 && $nix_success != 0 && $brew_success != 0 && $distro_success != 0 ]]; then
      echo -e "${YELLOW}$app_name not installed.${ENDCOLOR}"
      return 1
    fi
  }

  installP() {
    checkP $1
    if [[ $? != 1 ]]; then
      echo "$1 is already installed."
      return 0
    fi
    if [[ ${packageManagers[@]} =~ "nix" ]]; then
      echo "Attempting nix install..."
      nix-env -iA nixpkgs.$1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "brew" ]]; then
      echo "Attempting brew install..."
      brew install $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "apt" ]]; then
      echo "Attempting apt install..."
      sudo apt install $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "paru" ]]; then
      echo "Attempting paru install..."
      paru -Sy $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "pacman" ]]; then
      echo "Attempting pacman install..."
      sudo pacman -Sy $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "dnf" ]]; then
      echo "Attempting dnf install..."
      sudo dnf install $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "flatpak" ]]; then
      echo "Attempting flatpak install..."
      flatpak install $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    echo "ERROR - $1 not found."
    return 1
  }

  removeP() {
    checkP $1
    if [[ $? != 0 ]]; then
      echo "$1 is not installed."
      return 0
    fi
    if [[ ${packageManagers[@]} =~ "flatpak" ]]; then
      echo "Attempting flatpak uninstall..."
      flatpak uninstall $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "nix" ]]; then
      echo "Attempting nix uninstall..."
      nix-env --uninstall $1
    fi
    if [[ ${packageManagers[@]} =~ "brew" ]]; then
      echo "Attempting brew uninstall..."
      brew uninstall $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    if [[ ${packageManagers[@]} =~ "apt" ]]; then
      echo "Attempting apt uninstall..."
      sudo apt remove $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "pacman" ]]; then
      echo "Attempting pacman uninstall..."
      sudo pacman -Rs $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    elif [[ ${packageManagers[@]} =~ "dnf" ]]; then
      echo "Attempting dnf uninstall..."
      sudo dnf remove $1
      if [[ $? == 0 ]]; then
        return 0
      fi
    fi
    echo "ERROR - Failed to uninstall $1."
    return 1
  }

  # If no parameter or u
  echo "Available package managers: ${packageManagers[@]}"
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
    echo -e "${YELLOW}${UNDERLINE}[i] Usage:${ENDCOLOR}"
    echo -e "p (u)       ${FAINT}- update os${ENDCOLOR}"
    echo -e "p i package ${FAINT}- install package${ENDCOLOR}"
    echo -e "p r package ${FAINT}- remove package${ENDCOLOR}"
    echo -e "p c package ${FAINT}- check if package is installed${ENDCOLOR}"
    echo -e "${FAINT}Supported package managers: flatpak, nix, brew, apt, paru, pacman, dnf${ENDCOLOR}"
    return 1
  fi
)
