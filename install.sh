#! /bin/bash

source scripts/p.sh

# Install script dependencies
p i curl git rcm bat batdiff batman fzf eza nextcloud-client zoxide

if [ $(pwd) != "$HOME/dotfiles" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles
    cd dotfiles
fi

rcup -d dotfiles
dconf reset -f /
dconf load / < dconf-settings

xdg-settings set default-web-browser org.gnome.Epiphany.desktop

echo
echo -e "${GREEN}[I] Done. Rebooting in 5 seconds...${ENDCOLOR}"
sleep 5

systemctl reboot
reboot
