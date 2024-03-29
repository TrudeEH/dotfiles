#! /bin/bash

export NIXPKGS_ALLOW_UNFREE=1

detectDistro() {
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "macOS"
    else
        if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
            echo "Debian"
        elif [ "$(grep -Ei 'arch|manjaro|artix' /etc/*release)" ]; then
            echo "Arch"
        elif [ "$(grep -Ei 'fedora' /etc/*release)" ]; then
            echo "Fedora"
        else
            echo 1
            return 1
        fi
    fi
    return 0
}

d=$(detectDistro)
if [[ $d == "Debian" ]]; then
    sudo apt install -y curl
elif [[ $d == "Arch" ]]; then
    sudo pacman -Sy curl
elif [[ $d == "Fedora" ]]; then
    sudo dnf install curl
fi

if ! nix --version &>/dev/null; then
    echo -e "${YELLOW}[E] Nix not found.${ENDCOLOR}"
    echo -e "${GREEN}[+] Installing the Nix package manager...${ENDCOLOR}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    . $HOME/.nix-profile/etc/profile.d/nix.sh
    echo -e "${GREEN}[I] Installed Nix.${ENDCOLOR}"
fi

# Fix to add GUI nix-env apps to the GNOME launcher without having to restart
sudo ln -s "$HOME/.nix-profile/share/applications" "$HOME/.local/share/applications/nix-env"

# ============== HOME MANAGER ==============

# Install
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Apply config
mkdir -p $HOME/.config/home-manager
rm $HOME/.config/home-manager/home.nix
ln -s $HOME/dotfiles/home.nix $HOME/.config/home-manager/home.nix

# home-manager -b backup switch
