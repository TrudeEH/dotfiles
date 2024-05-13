#! /bin/bash
sudo timedatectl set-timezone Europe/Lisbon

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
paru -Sy curl git stow bat fzf less nextcloud-client

# Install DE
paru -Sy mpd ncmpcpp dunst xdg-desktop-portal-wlr xdg-desktop-portal sway swaybg swaylock waybar wofi foot grim slurp wl-clipboard xorg-xwayland polkit-gnome

# Install GUI Apps
paru -Sy brave gnome-podcasts r-quick-share

# Install CLI Apps
paru -Sy gdu toipe bottom w3m newsboat iamb tmux ollama neovim transmission-cli mutt pass pass-git-helper

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
