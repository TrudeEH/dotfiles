#! /bin/bash
sudo timedatectl set-timezone Europe/Lisbon

compile() {
  cd $1
  sudo make clean install
  cd ..
}

# Install Paru
if [ ! $(command -v paru) ]; then
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
fi

# Install script dependencies
paru -Sy curl git stow bat nextcloud-client

# Install DE
paru -Sy picom dunst scrot freetype2 libx11 libxft libxinerama xorg-xinit
compile dwm
compile st
compile dmenu
compile slock
compile slstatus

# Install CLI Apps
paru -Sy mpv gdu toipe bottom w3m newsboat iamb tmux ollama neovim transmission-cli mutt pass pass-git-helper fzf

# Browser and browser tools
paru -Sy brave-bin

if [ $(pwd) != "$HOME/dotfiles" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles --depth=1
    cd dotfiles
fi

echo -e "${GREEN}[+] Symlinking dotfiles...${ENDCOLOR}"
stow -v -t $HOME dotfiles --adopt
git diff
git reset --hard

# Reload fonts
fc-cache -fv

# link wallpaper
mkdir -p "/usr/share/backgrounds"
sudo cp -f ~/dotfiles/bg.png /usr/share/backgrounds/bg.png

xdg-settings set default-web-browser brave-browser.desktop

# Import Files, Passwords and Keys
source dotfiles/.bashrc
ncs
gpg --import ~/Nextcloud/SYNC/exported-keys/private.pgp
gpg --import ~/Nextcloud/SYNC/exported-keys/public.pgp
gpg --import-ownertrust < ~/Nextcloud/SYNC/exported-keys/trustlevel.txt
ln -s ~/Nextcloud/SYNC/password-store ~/.password-store

echo
echo -e "${GREEN}[I] Done.${ENDCOLOR}"
