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
}

d=$(detectDistro)
if [[ $d == "Debian" ]]; then
    sudo apt install -y curl git
elif [[ $d == "Arch" ]]; then
    sudo pacman -Sy curl git
elif [[ $d == "Fedora" ]]; then
    sudo dnf install curl git
fi

if [ $(pwd) != "$HOME/dotfiles" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles
    cd dotfiles
fi

if ! nix --version &>/dev/null; then
    echo -e "${YELLOW}[E] Nix not found.${ENDCOLOR}"
    echo -e "${GREEN}[+] Installing the Nix package manager...${ENDCOLOR}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    . $HOME/.nix-profile/etc/profile.d/nix.sh
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    echo -e "${GREEN}[I] Installed Nix.${ENDCOLOR}"
fi

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
