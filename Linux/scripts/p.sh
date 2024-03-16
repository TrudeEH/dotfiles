#! /bin/bash
# Cross-distro package manager wrapper

source ~/dotfiles/scripts/color.sh

d() {
	if [ "$(uname -s)" = "Darwin" ]; then
		echo 3
	else
		if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
			echo 1
		elif [ "$(grep -Ei 'arch|manjaro|artix' /etc/*release)" ]; then
			echo 2
		else
			echo 0
		fi
	fi

}

m() {
	d=$(d)
	if [ $d -eq 2 ]; then
		~/dotfiles/scripts/arch-maintenance.sh
	elif [ $d -eq 1 ]; then
		~/dotfiles/scripts/debian-maintenance.sh
	elif [ $d -eq 3 ]; then
		~/dotfiles/scripts/macos-maintenance.sh
	else
		echo -e "${RED}[E] Distro not supported.${ENDCOLOR}"
		return 1
	fi
}

p() {
	# Detect distro type
	d=$(d)
	if [ $d -eq 1 ]; then
		distro="DEB"
		update="sudo apt update; sudo apt upgrade; sudo apt autoremove"
		install="sudo apt install"
		remove="sudo apt remove"
	elif [ $d -eq 2 ]; then
		if pacman -Qs paru >/dev/null; then
			update="paru -Syu"
			install="paru -S"
			remove="paru -R"
		else
			update="sudo pacman -Syu"
			install="sudo pacman -S"
			remove="sudo pacman -R"
		fi
		distro="ARCH"
	elif [ $d -eq 3 ]; then
		distro="MAC"
		update="brew update; brew upgrade"
		install="brew install"
		remove="brew uninstall"
	else
		echo "[E] Distro not supported."
		return 1
	fi

	# Detect if flatpak is installed.
	if flatpak --version &>/dev/null; then
		flatpak=true
	else
		flatpak=false
	fi

	# If no parameter
	if [ -z $1 ] || [ $1 = "u" ]; then
		echo -e "${GREEN}[+] Updating packages...${ENDCOLOR}"
		bash -c $update
		if $flatpak; then
			echo
			echo -e "${GREEN}[+] Updating flatpaks...${ENDCOLOR}"
			flatpak upgrade
		fi
		echo -e "${GREEN}[i] done.${ENDCOLOR}"
		return 0
	elif [ $1 = "i" ]; then # If first parameter is i (install)
		echo -e "${GREEN}[+] Searching for $2 on the repository...${ENDCOLOR}"
		bash -c "$install $2"
		if [ $? -eq 0 ]; then
			echo -e "${GREEN}[i] $2 installed.${ENDCOLOR}"
			return 0
		else
			if $flatpak; then
				echo
				echo -e "${YELLOW}[E] $2 not found.${ENDCOLOR}"
				echo -e "${GREEN}[+] Searching for $2 as a flatpak...${ENDCOLOR}"
				echo
				flatpak install $2 2>/dev/null
				if [ $? -eq 0 ]; then
					echo -e "${GREEN}[i] $2 installed.${ENDCOLOR}"
					return 0
				fi
			fi
			echo -e "${RED}[E] $2 not found or already installed.${ENDCOLOR}"
			return 2
		fi
	elif [ $1 = "r" ]; then # If first parameter is r (remove)
		echo -e "${YELLOW}[+] Removing $2...${ENDCOLOR}"
		bash -c "$remove $2"
		if [ $? -eq 0 ]; then
			echo -e "${GREEN}[i] $2 removed.${ENDCOLOR}"
			return 0
		else
			if $flatpak; then
				echo
				echo -e "${YELLOW}[E] $2 not found.${ENDCOLOR}"
				echo "[+] Searching for $2 as a flatpak..."
				echo -e "${GREEN}[+] Searching for $2 as a flatpak...${ENDCOLOR}"
				echo
				flatpak remove $2 2>/dev/null
				if [ $? -eq 0 ]; then
					echo -e "${GREEN}[i] $2 removed.${ENDCOLOR}"
					return 0
				fi
			fi
			echo -e "${RED}[E] $2 not found.${ENDCOLOR}"
			return 2
		fi
	elif [ $1 = "c" ]; then # If first parameter is c (check)
		if [ "$distro" = "DEB" ]; then
			if dpkg-query -W -f='${Status}' $2 2>/dev/null | grep -q "install ok installed"; then
				echo true
				return 0
			else
				if $flatpak; then
					flatpak list | grep $2 &>/dev/null
					if [ $? -eq 0 ]; then
						echo true
						return 0
					fi
				fi
				echo false
				return 1
			fi
		elif [ "$distro" = "ARCH" ]; then
			if pacman -Qs $2 >/dev/null; then
				echo true
				return 0
			else
				if $flatpak; then
					flatpak list | grep -i $2 &>/dev/null
					if [ $? -eq 0 ]; then
						echo true
						return 0
					fi
				fi
				echo false
				return 1
			fi
		elif [ "$distro" = "MAC" ]; then
			if brew list | grep $2 >/dev/null; then
				echo true
				return 0
			else
				echo false
				return 1
			fi
		else
			echo 2
		fi
	else
		echo -e "${YELLOW}${UNDERLINE}[i] Usage:${ENDCOLOR}"
		echo -e "p (u)       ${FAINT}- update os${ENDCOLOR}"
		echo -e "p i package ${FAINT}- install package${ENDCOLOR}"
		echo -e "p r package ${FAINT}- remove package${ENDCOLOR}"
		echo -e "p c package ${FAINT}- check if package is installed (true/false; 2 -> ERROR)${ENDCOLOR}"
		echo -e "d           ${FAINT}- returns 1 -> Debian; 2 -> Arch; 0 -> Error${ENDCOLOR}"
		echo -e "m           ${FAINT}- maintenance script${ENDCOLOR}"
		echo
		echo -e "${YELLOW}${UNDERLINE}[i] Order of operations:${ENDCOLOR}"
		echo "1 - Check distro repos"
		echo "2 - Check AUR if on Arch"
		echo "3 - Check flatpaks (only if flatpak support is enabled)"
	fi
}