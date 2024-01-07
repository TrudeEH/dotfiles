#! /bin/bash
# Cross-distro package manager wrapper

d() {
	if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
		echo 1
	elif [ "$(grep -Ei 'arch|manjaro|artix' /etc/*release)" ]; then
		echo 2
	else
		echo 0
	fi
}

m() {
	d=$(d)
	if [ $d == 2 ]; then
		~/dotfiles/scripts/arch-maintenance.sh
	elif [ $d == 1 ]; then
		~/dotfiles/scripts/debian-maintenance.sh
	else
		echo "ERROR - Distro not supported."
		return 1
	fi
}

p() {
	# Detect distro type
	if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
		distro="DEB"
		update="sudo apt update; sudo apt upgrade; sudo apt autoremove"
		install="sudo apt install"
		remove="sudo apt remove"
	elif [ "$(grep -Ei 'arch|manjaro|artix' /etc/*release)" ]; then
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
	if [ -z $1 ] || [ $1 == "u" ]; then
		echo "[+] Updating distro packages..."
		$update
		if $flatpak; then
			echo
			echo "[+] Updating flatpaks..."
			flatpak upgrade
		fi
		echo "[I] done."
		return 0
	elif [ $1 == "i" ]; then # If first parameter is i (install)
		echo "[+] Searching for $2 on the distro repos..."
		$install $2 2>/dev/null
		if [ $? == 0 ]; then
			echo "[I] $2 was installed."
			return 0
		else
			if $flatpak; then
				echo
				echo "[E] $2 not found."
				echo "[+] Searching for $2 as a flatpak..."
				echo
				flatpak install $2 2>/dev/null
				if [ $? == 0 ]; then
					echo "[I] $2 was installed."
					return 0
				fi
			fi
			echo "[E] $2 not found or already installed."
			return 2
		fi
	elif [ $1 == "r" ]; then # If first parameter is r (remove)
		echo "[+] Removing $2..."
		$remove $2 2>/dev/null
		if [ $? == 0 ]; then
			echo "[I] $2 was removed."
			return 0
		else
			if $flatpak; then
				echo
				echo "[E] $2 not found."
				echo "[+] Searching for $2 as a flatpak..."
				echo
				flatpak remove $2 2>/dev/null
				if [ $? == 0 ]; then
					echo "[I] $2 was removed."
					return 0
				fi
			fi
			echo "[E] $2 not found."
			return 2
		fi
	elif [ $1 == "c" ]; then # If first parameter is c (check)
		if [ "$distro" == "DEB" ]; then
			if dpkg-query -W -f='${Status}' $2 2>/dev/null | grep -q "install ok installed"; then
				echo true
				return 0
			else
				if $flatpak; then
					flatpak list | grep $2 &>/dev/null
					if [ $? == 0 ]; then
						echo true
						return 0
					fi
				fi
				echo false
				return 1
			fi
		elif [ "$distro" == "ARCH" ]; then
			if pacman -Qs $2 >/dev/null; then
				echo true
				return 0
			else
				if $flatpak; then
					flatpak list | grep -i $2 &>/dev/null
					if [ $? == 0 ]; then
						echo true
						return 0
					fi
				fi
				echo false
				return 1
			fi
		else
			echo 2
		fi
	else
		echo "[I] Usage:"
		echo "p (u)       -> update os"
		echo "p i package -> install package"
		echo "p r package -> remove package"
		echo "p c package -> check if package is installed (true/false; 2 -> ERROR)"
		echo "d           -> returns 1 -> Debian; 2 -> Arch; 0 -> Error"
		echo "m           -> maintenance script"
		echo
		echo "[I] Order of operations:"
		echo "1 - Check distro repos"
		echo "2 - Check AUR if on Arch"
		echo "3 - Check flatpaks (only if flatpak support is enabled)"
	fi
}
