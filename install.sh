#! /bin/bash

source ./scripts/p.sh
source ./scripts/color.sh

dist=$(d)

if [ $dist == 0 ]; then
	echo -e "${RED}[E] Distro not supported.${ENDCOLOR}"
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
echo -e "${GREEN}[+] Updating packages...${ENDCOLOR}"
p

# Install git
if p c git &>/dev/null; then
	echo -e "${GREEN}[i] git is installed.${ENDCOLOR}"
else
	echo -e "${GREEN}[+] Installing git...${ENDCOLOR}"
	p i git
	echo -e "${GREEN}[i] git installed.${ENDCOLOR}"
fi

# Mirrors
if [ $dist == 2 ]; then
	if ask "Choose best mirrors (LONG TIME)?"; then
		echo -e "${GREEN}[+] Choosing mirrors...${ENDCOLOR}"
		p i reflector
		sudo reflector --sort rate -p https --save /etc/pacman.d/mirrorlist --verbose
		echo -e "${GREEN}[i] New mirrors applied.${ENDCOLOR}"
	else
		echo -e "${RED}[i] Cancelled.${ENDCOLOR}"
	fi
fi

# Install paru
if [ $dist == 2 ]; then
	if p c paru &>/dev/null; then
		echo -e "${GREEN}[i] Paru is installed.${ENDCOLOR}"
	else
		echo -e "${GREEN}[+] Installing paru...${ENDCOLOR}"
		sudo pacman -S --needed base-devel
		git clone https://aur.archlinux.org/paru.git
		cd paru
		makepkg -si
		cd ..
		rm -rf paru
		echo -e "${GREEN}[i] Paru installed.${ENDCOLOR}"
	fi
fi

# Enable bluetooth support
if [ $dist == 2 ]; then
	if p c bluetooth &>/dev/null; then
		echo -e "${GREEN}[i] Bluetooth is enabled.${ENDCOLOR}"
	else
		if ask "Enable bluetooth?"; then
			echo -e "${GREEN}[+] Installing bluetooth support...${ENDCOLOR}"
			sudo pacman -S bluez bluez-utils
			sudo systemctl start bluetooth.service
			sudo systemctl enable bluetooth.service
			echo -e "${GREEN}[i] Bluetooth enabled.${ENDCOLOR}"
		else
			echo -e "${RED}[i] Cancelled.${ENDCOLOR}"
		fi
	fi
fi

# Enable printer support
if [ $dist == 2 ]; then
	if p c cups &>/dev/null; then
		echo -e "${GREEN}[i] CUPS is enabled.${ENDCOLOR}"
	else
		if ask "Enable CUPS (printer)?"; then
			echo -e "${GREEN}[+] Installing CUPS...${ENDCOLOR}"
			sudo pacman -S cups
			sudo systemctl start cups
			sudo systemctl start cups.service
			sudo systemctl enable cups
			sudo systemctl enable cups.service
			echo -e "${GREEN}[i] CUPS enabled.${ENDCOLOR}"
		else
			echo -e "${RED}[i] Cancelled.${ENDCOLOR}"
		fi
	fi
fi

# Install Icon theme
if ls /usr/share/icons/ | grep -i Papirus &>/dev/null; then
	echo -e "${GREEN}[i] Icon theme is installed.${ENDCOLOR}"
else
	echo -e "${GREEN}[+] Downloading Papirus icon theme...${ENDCOLOR}"
	wget -qO- https://git.io/papirus-icon-theme-install | sh
	gsettings set org.gnome.desktop.interface icon-theme 'Papirus Dark'
	echo -e "${GREEN}[i] Theme is set.${ENDCOLOR}"
fi

# Install Cursor theme
if ls /usr/share/icons/ | grep -i bibata &>/dev/null; then
	echo -e "${GREEN}[i] Cursor theme is installed.${ENDCOLOR}"
else
	echo -e "${GREEN}[+] Downloading Bibata cursor theme...${ENDCOLOR}"
	p i bibata-cursor-theme
	gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'
	echo -e "${GREEN}[i] Cursor theme set.${ENDCOLOR}"
fi

# Install Nerd Font
if [ $dist == 2 ]; then
	if p c ttf-jetbrains-mono-nerd &>/dev/null; then
		echo -e "${GREEN}[i] JetBrains font is installed.${ENDCOLOR}"
	else
		echo -e "${GREEN}[+] Installing JetBrains font.${ENDCOLOR}"
		p i ttf-jetbrains-mono-nerd
		echo -e "${GREEN}[i] JetBrains font installed.${ENDCOLOR}"
	fi
else
	if p c fonts-jetbrains-mono &>/dev/null; then
		echo -e "${GREEN}[i] JetBrains font is installed.${ENDCOLOR}"
	else
		echo -e "${GREEN}[+] Installing JetBrains font.${ENDCOLOR}"
		p i fonts-jetbrains-mono
		echo -e "${GREEN}[i] JetBrains font installed.${ENDCOLOR}"
	fi
fi

# Enable minimize button
echo -e "${GREEN}[+] Adding the minimize button...${ENDCOLOR}"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,close"

# Enable flatpak support
if p c flatpak &>/dev/null; then
	echo -e "${GREEN}[i] Flatpaks are supported.${ENDCOLOR}"
else
	if ask "Enable flatpak?"; then
		echo -e "${GREEN}[+] Adding flatpak support...${ENDCOLOR}"
		p i flatpak
		flatpak install flatseal
		sudo flatpak override --filesystem=$HOME/.themes
		sudo flatpak override --filesystem=$HOME/.icons
		echo -e "${GREEN}[+] Flatpak support added.${ENDCOLOR}"
	else
		echo -e "${RED}[i] Cancelled.${ENDCOLOR}"
	fi
fi

# Install Timeshift
if p c flatpak &>/dev/null; then
	echo -e "${GREEN}[i] Timeshift is installed.${ENDCOLOR}"
else
	if ask "Install Timeshift?"; then
		echo -e "${GREEN}[+] Installing Timeshift...${ENDCOLOR}"
		p i timeshift
		sudo systemctl enable cronie
		sudo systemctl start cronie
		echo -e "${GREEN}[i] Timeshift installed.${ENDCOLOR}"
	else
		echo -e "${RED}[i] Cancelled.${ENDCOLOR}"
	fi
fi

# Copy configs
echo -e "${GREEN}[+] Configuring system...${ENDCOLOR}"
cp -rf homeConfigs/.* ~

# Enable bash case insensitive completion
cat /etc/inputrc | grep completion-ignore-case
if [ $? == 1 ]; then
	echo 'set completion-ignore-case On' | sudo tee -a /etc/inputrc
fi

echo -e "${GREEN}${BOLD}[i] All done.${ENDCOLOR}"
