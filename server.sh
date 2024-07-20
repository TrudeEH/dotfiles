#! /bin/bash

if ! command -v dialog; then
  sudo apt-get install dialog -y
fi

# Set dialog colors
cp -f dotfiles/.dialogrc  $HOME/.dialogrc

BACKTITLE="Trude's Linux Server Toolkit"
dialog --erase-on-exit \
       --backtitle "$BACKTITLE" \
       --checklist "Use the arrow keys and SPACE to select, then press ENTER." 30 90 5 \
        "1" "Update OS" "on"\
        "2" "Copy Dotfiles" "on"\
        "3" "Install CasaOS UI" "off"\
        "4" "Install Tailscale (VPN)" "on" 2> choice.tmp
main_menu=$( cat choice.tmp )
rm choice.tmp

for selection in $main_menu; do
  if [ "$selection" = "1" ]; then
    # --- UPDATE OS ---

    dialogUpdate() {
      dialog --backtitle "$BACKTITLE" --title "Update Debian and Packages" \
	       --mixedgauge "Updating..." \
	       0 0 $1 \
         "Update repos" "$2" \
         "Update distro" "$3" \
         "Update packages" "$4" \
         "Clean up " "$5"
    }

    dialogUpdate 0 7 4 4 4

    sudo apt-get update &> /dev/null
    dialogUpdate 15 5 7 4 4

    sudo apt-get dist-upgrade -y &> /dev/null
    dialogUpdate 35 5 5 7 4DWM

    sudo apt-get upgrade -y &> /dev/null
    dialogUpdate 80 5 5 5 7

    sudo apt-get clean &> /dev/null
    sudo apt-get autoremove -y &> /dev/null
    dialogUpdate 100 5 5 5 5
  fi

  if [ "$selection" = "2" ]; then
    # Neovim
    dialog --erase-on-exit \
           --backtitle "$BACKTITLE" \
           --title "Install/Update Neovim?" \
           --yesno "Nvim will be compiled from source. This may take a long time, depending on your device." 10 40

    if [ "$?" -eq 0 ]; then
      # NVIM has to be compiled from source to support arm64 and i386 devices, for example.
      sudo apt install -y ninja-build gettext cmake unzip curl build-essential
      git clone https://github.com/neovim/neovim --depth 1
      cd neovim
      git checkout stable
      make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
      cd ..
      rm -rf neovim
    fi

    echo "Installing utilities..."
    sudo apt install -y htop fzf git wget curl bash-completion tmux

    echo "Copying dotfiles..."
    cp -vrf dotfiles/.* $HOME
    cp -vrf dotfiles/* $HOME

    echo "Loading fonts..."
    fc-cache -f
  fi

  if [ "$selection" = "3" ]; then
    # --- Install CasaOS ---
    sudo apt install -y curl
    curl -fsSL https://get.casaos.io | sudo bash
  fi

  if [ "$selection" = "4" ]; then
    clear
    echo "-------------------------"
    echo "--- Install Tailscale ---"
    echo "-------------------------"
    echo
    echo

    curl -fsSL https://tailscale.com/install.sh | sh
  fi
done
