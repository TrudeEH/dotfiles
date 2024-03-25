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

detectDistro() {
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "macOS"
    else
        if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
            echo "Debian"
        elif [ "$(grep -Ei 'arch|manjaro|artix' /etc/*release)" ]; then
            echo "Arch"
        else
            echo 1
            return 1
        fi
    fi
    return 0
}

oneline() {
    # Print a command's output as a single line only.
    # Example usage: for f in 'first line' 'second line' '3rd line'; do echo "$f"; sleep 1; done | oneline
    local ws
    while IFS= read -r line; do
        if ((${#line} >= $COLUMNS)); then
            # Moving cursor back to the front of the line so user input doesn't force wrapping
            printf '\r%s\r' "${line:0:$COLUMNS}"
        else
            ws=$(($COLUMNS - ${#line}))
            # by writing each line twice, we move the cursor back to position
            # thus: LF, content, whitespace, LF, content
            printf '\r%s%*s\r%s' "$line" "$ws" " " "$line"
        fi
    done
    echo
}

p() (
    distro=$(detectDistro)
    update() {
        if [[ $distro == "Arch" ]]; then
            ~/dotfiles/Linux/scripts/arch-maintenance.sh
        elif [[ $distro == "Debian" ]]; then
            ~/dotfiles/Linux/scripts/debian-maintenance.sh
        elif [[ $distro == "macOS" ]]; then
            ~/dotfiles/macOS/scripts/macos-maintenance.sh
        else
            echo -e "${RED}[E] System not supported.${ENDCOLOR}"
            return 1
        fi
    }

    check() {
        nix_apps=$(nix-env -q)
        if [[ $distro == "Debian" ]]; then
            distro_apps=$(dpkg-query -l | grep '^ii' | awk '{print $2}')
        elif [[ $distro == "Arch" ]]; then
            distro_apps=$(pacman -Q)
        else
            distro_apps=""
        fi

        app_name=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        app_name=$(echo "$app_name" | tr " " -)

        echo $nix_apps | grep -wq $app_name
        nix_success=$?
        if [[ $nix_success == 0 ]]; then
            echo -e "${GREEN}Nix: $(echo $nix_apps | tr ' ' '\n' | grep -w $app_name)${ENDCOLOR}"
        fi

        echo $distro_apps | grep -Eq "(^|\s)$app_name($|\s)"
        distro_success=$?
        if [[ $distro_success == 0 ]]; then
            echo -e "${GREEN}$distro: $(echo $distro_apps | tr ' ' '\n' | grep -E "(^|\s)$app_name($|\s)")${ENDCOLOR}"
        fi

        if [[ $nix_success == 0 && $distro_success == 0 ]]; then
            return 2 #both
        elif [[ $nix_success == 0 ]]; then
            return 3 #nix
        elif [[ $distro_success == 0 ]]; then
            return 4 #distro
        else
            echo -e "${YELLOW}$app_name not installed.${ENDCOLOR}"
            return 1
        fi

        # Get a list of all apps -> see if it's installed and print what installed it, and version.
    }

    if [[ $distro == "Debian" ]]; then
        install="sudo apt-get install"
        remove="sudo apt-get remove"
        search="apt-cache search"
    elif [[ $distro == "Arch" ]]; then
        if pacman -Qs paru >/dev/null; then
            install="paru -S"
            remove="paru -R"
            search="paru -Si"
        else
            install="sudo pacman -S"
            remove="sudo pacman -R"
            search="pacman -Ss"
        fi
    fi

    # Install Nix.
    if ! nix --version &>/dev/null; then
        echo -e "${YELLOW}[E] Nix not found.${ENDCOLOR}"
        echo -e "${GREEN}[+] Installing the Nix package manager...${ENDCOLOR}"
        curl -L https://nixos.org/nix/install | sh
        . $HOME/.nix-profile/etc/profile.d/nix.sh
        echo -e "${GREEN}[I] Installed Nix.${ENDCOLOR}"
    fi

    # If no parameter
    if [ -z $1 ] || [ $1 = "u" ]; then
        echo -e "${GREEN}[+] Running update script...${ENDCOLOR}"
        update
        echo -e "${GREEN}[+] Updating Nix...${ENDCOLOR}"
        nix-env -u
        return 0
    elif [ $1 = "i" ]; then # If first parameter is i (install)
        check $2
        if [[ $? != 1 ]]; then
            echo "$2 is already installed."
            return 1
        fi

        nix search nixpkgs $2 --extra-experimental-features 'nix-command flakes' &>/dev/null
        nix_found=$?

        $search $2 &>/dev/null
        distro_found=$?

        if [[ $nix_found == 0 && $distro_found == 0 ]]; then
            echo "1. Nix: $2 found."
            echo "2. $distro: $2 found."

            echo -n "Choose a package manager: "
            read p_choice
            if [[ $p_choice == 1 ]]; then
                nix-env -iA nixpkgs.$2
            elif [[ $p_choice == 2 ]]; then
                $install $2
            else
                return 1
            fi
            return 0
        fi
        if [[ $nix_found == 0 ]]; then
            nix-env -iA nixpkgs.$2
        elif [[ $distro_found == 0 ]]; then
            $install $2
        else
            echo "$2 not found."
            return 1
        fi
        return 0
    elif [ $1 = "r" ]; then # If first parameter is r (remove)
        check $2
        check_result=$?

        if [[ $check_result == 2 ]]; then
            echo "1. Nix: $2 installed."
            echo "2. $distro: $2 installed."

            echo -n "Choose a package manager: "
            read p_choice
            if [[ $p_choice == 1 ]]; then
                nix-env -e $2
            elif [[ $p_choice == 2 ]]; then
                $remove $2
            else
                return 1
            fi
            return 0
        fi
        if [[ $check_result == 3 ]]; then
            nix-env -e $2
        elif [[ $check_result == 4 ]]; then
            $remove $2
        else
            echo "$2 is not installed."
            return 1
        fi
        return 0
    elif [ $1 = "c" ]; then # If first parameter is c (check)
        check $2
    else
        echo -e "${YELLOW}${UNDERLINE}[i] Usage:${ENDCOLOR}"
        echo -e "p (u)       ${FAINT}- update os${ENDCOLOR}"
        echo -e "p i package ${FAINT}- install package${ENDCOLOR}"
        echo -e "p r package ${FAINT}- remove package${ENDCOLOR}"
        echo -e "p c package ${FAINT}- check if package is installed (true/false; 2 -> ERROR)${ENDCOLOR}"
        return 1
    fi
)
