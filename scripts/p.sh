#! /bin/bash
# Cross-distro package manager

# p 		  -> update os
# p i package -> install package
# p r package -> remove package
# p c package -> check if package is installed (0 -> installed; 1 -> not installed; 2 -> ERROR)
# d 		  -> returns 1 -> Debian; 2 -> Arch; 0 -> Error

d() {
	if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
		echo 1
	elif [ "$(grep -Ei 'arch|manjaro|artix' /etc/*release)" ]; then
		echo 2
	else
		echo 0
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
		distro="ARCH"
		update="sudo pacman -Syu"
		install="sudo pacman -S"
		remove="sudo pacman -R"
	else
		echo "DISTRO NOT SUPPORTED"
		return 1
	fi

	# If no parameter
	if [ -z $1 ]; then
		$update
		return 0
	fi

	# If first parameter is i (install)
	if [ $1 == "i" ]; then
		$install $2
		if [ $? == 0 ]; then
			return 0
		else
			return 2
		fi
	fi

	# If first parameter is r (remove)
	if [ $1 == "r" ]; then
		$remove $2
		if [ $? == 0 ]; then
			return 0
		else
			return 2
		fi
	fi

	if [ $1 == "c" ]; then
		if [ "$distro" == "DEB" ]; then
			if dpkg-query -W -f='${Status}' $2 2>/dev/null | grep -q "install ok installed"; then
				echo 0
			else
				echo 1
			fi
		elif [ "$distro" == "ARCH" ]; then
			if pacman -Qs $2 >/dev/null; then
				echo 0
			else
				echo 1
			fi
		else
			echo 2
		fi
	fi
}
