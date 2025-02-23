#! /bin/bash
sudo timedatectl set-timezone Europe/Lisbon

# Install script dependencies
pacman -Sy curl git bat fzf less

# Install DE
pacman -Sy mpd ncmpcpp dunst xdg-desktop-portal-wlr xdg-desktop-portal sway swaybg swaylock waybar wofi foot grim slurp wl-clipboard xorg-xwayland polkit-gnome

# Install CLI Apps
pacman -Sy gdu tmux neovim

if [ $(pwd) != "$HOME/dotfiles" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles --depth=1
    cd dotfiles
fi

echo -e "${GREEN}[+] Copying dotfiles...${ENDCOLOR}"
cp -rf dotfiles/. $HOME

# Reload fonts
fc-cache -fv

# link wallpaper
mkdir -p "/usr/share/backgrounds"
sudo cp -f ~/dotfiles/bg.png /usr/share/backgrounds/bg.png

echo
echo -e "${GREEN}[I] Done.${ENDCOLOR}"
