#! /bin/bash

source ./scripts/p.sh # Universal package manager
dist=$(d)

if [ $dist == 0 ]; then
	echo "ERROR - Distro not supported."
	return 1
fi

# Ask Y/n
function ask() {
	read -p "$1 (Y/n): " resp
	if [ -z "$resp" ]; then
		response_lc="y" # empty is Yes
	else
		response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
	fi

	[ "$response_lc" = "y" ]
}

# Upgrade
echo "Updating packages..."
p
p i git

# Mirrors
if [ $dist == 2 ]; then
	if ask "Choose best mirrors (LONG TIME)?"; then
		sudo pacman -S reflector
		sudo reflector --sort rate -p https --save /etc/pacman.d/mirrorlist --verbose
		read -p "Press enter to continue."
	fi
fi

# Install paru
if [ $dist == 2 ]; then
	paru=$(pacman -Q paru)
	if [[ -n "$paru" ]]; then
		echo -e "\e[32m[I] Paru is already installed.\e[0m"
	else
		sudo pacman -S --needed base-devel
		git clone https://aur.archlinux.org/paru.git
		cd paru
		makepkg -si
		cd ..
		rm -rf paru
	fi
	read -p "Press enter to continue."
fi

# Enable bluetooth support
if [ $dist == 2 ]; then
	if ask "Enable bluetooth?"; then
		sudo pacman -S bluez bluez-utils
		sudo systemctl start bluetooth.service
		sudo systemctl enable bluetooth.service
	fi
fi

# Enable printer support
if [ $dist == 2 ]; then
	if ask "Enable CUPS (printer)?"; then
		sudo pacman -S cups
		sudo systemctl start cups
		sudo systemctl start cups.service
		sudo systemctl enable cups
		sudo systemctl enable cups.service
	fi
fi

# Install Icon theme
echo "Installing Papirus Icon Theme..."
wget -qO- https://git.io/papirus-icon-theme-install | sh
gsettings set org.gnome.desktop.interface icon-theme 'Papirus Dark'

# Install Cursor theme
echo "Installing Cursor Theme..."
p i bibata-cursor-theme
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'

# Install Nerd Font
echo "Installing JetBrains font..."
if [ $dist == 2 ]; then
	p i ttf-jetbrains-mono-nerd
else
	p i fonts-jetbrains-mono
fi

# Enable minimize button
echo "Enabling minimize button..."
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,close"

# Enable flatpak support
if ask "Enable flatpak?"; then
	p i flatpak
	flatpak install flatseal
	sudo flatpak override --filesystem=$HOME/.themes
	sudo flatpak override --filesystem=$HOME/.icons
fi

# Install Timeshift
if ask "Install Timeshift?"; then
	p i timeshift
	sudo systemctl enable cronie
	sudo systemctl start cronie
fi

# Copy configs
echo "Configuring system..."
cp -rf homeConfigs/.* ~

# Enable bash case insensitive completion
cat /etc/inputrc | grep completion-ignore-case
if [ $? == 1 ]; then
	echo 'set completion-ignore-case On' | sudo tee -a /etc/inputrc
fi
