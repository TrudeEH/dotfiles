#!/bin/bash
E='echo -e'
e='echo -en'
trap "R;exit" 2
ESC=$($e "\e")
TPUT() { $e "\e[${1};${2}H"; }
CLEAR() { $e "\ec"; }
CIVIS() { $e "\e[?25l"; }
MARK() { $e "\e[7m"; }
UNMARK() { $e "\e[27m"; }
R() {
   CLEAR
   stty sane
   CLEAR
}
HEAD() {
   for each in $(seq 1 12); do
      $E "   \xE2\x94\x82                                          \xE2\x94\x82"
   done
   MARK
   TPUT 1 5
   $E "            Trude's Toolkit               "
   UNMARK
}
i=0
CLEAR
CIVIS
NULL=/dev/null
FOOT() {
   MARK
   TPUT 12 5
   $E " UP \xE2\x86\x91 \xE2\x86\x93 DOWN    ENTER - SELECT,NEXT       "
   UNMARK
}
ARROW() {
   IFS= read -s -n1 key 2>/dev/null >&2
   if [[ $key = $ESC ]]; then
      read -s -n1 key 2>/dev/null >&2
      if [[ $key = \[ ]]; then
         read -s -n1 key 2>/dev/null >&2
         if [[ $key = A ]]; then echo up; fi
         if [[ $key = B ]]; then echo dn; fi
      fi
   fi
   if [[ "$key" == "$($e \\x0A)" ]]; then echo enter; fi
}
M0() {
   TPUT 4 12
   $e "Switch to Debian testing"
}
M1() {
   TPUT 5 12
   $e "Install GNOME"
}
M2() {
   TPUT 6 12
   $e "Install DWM"
}
M3() {
   TPUT 7 12
   $e "Install Dotfiles"
}
M4() {
   TPUT 8 12
   $e "Enable Flatpak support"
}
M5() {
   TPUT 9 12
   $e "EXIT   "
}
LM=5
MENU() { for each in $(seq 0 $LM); do M${each}; done; }
POS() {
   if [[ $cur == up ]]; then ((i--)); fi
   if [[ $cur == dn ]]; then ((i++)); fi
   if [[ $i -lt 0 ]]; then i=$LM; fi
   if [[ $i -gt $LM ]]; then i=0; fi
}
REFRESH() {
   after=$((i + 1))
   before=$((i - 1))
   if [[ $before -lt 0 ]]; then before=$LM; fi
   if [[ $after -gt $LM ]]; then after=0; fi
   if [[ $j -lt $i ]]; then
      UNMARK
      M$before
   else
      UNMARK
      M$after
   fi
   if [[ $after -eq 0 ]] || [ $before -eq $LM ]; then
      UNMARK
      M$before
      M$after
   fi
   j=$i
   UNMARK
   M$before
   M$after
}
INIT() {
   R
   HEAD
   FOOT
   MENU
}
SC() {
   REFRESH
   MARK
   $S
   $b
   cur=$(ARROW)
}
ES() {
   MARK
   $e "ENTER = main menu "
   $b
   read
   INIT
}
INIT
while [[ "$O" != " " ]]; do
   case $i in
   0)
      S=M0
      SC
      if [[ $cur == enter ]]; then
         R
         # Debian testing
         sudo cp -f ./debian-sources.list /etc/apt/sources.list
         sudo apt update
         sudo apt upgrade -y
         sudo apt full-upgrade -y
         sudo apt autoremove -y
         sudo apt autoclean -y
         ES
      fi
      ;;
   1)
      S=M1
      SC
      if [[ $cur == enter ]]; then
         R
         # GNOME Install
         sudo apt install gnome-core
         ES
      fi
      ;;
   2)
      S=M2
      SC
      if [[ $cur == enter ]]; then
         R
         # DWM Install
         compile() {
            cd programs/$1
            sudo make clean install
            cd ../..
         }

         # Install Dependencies
         sudo apt install -y xorg picom libx11-dev libxft-dev libxinerama-dev build-essential libxrandr-dev policykit-1-gnome dbus-x11 pipewire-audio wireplumber pipewire-pulse pipewire-alsa network-manager firefox-esr feh scrot dunst
         systemctl --user --now enable wireplumber.service
         sudo systemctl enable NetworkManager

         # Compile
         for program in "dwm" "dmenu" "slock" "st" "tabbed" "dwmblocks"; do
            compile $program
         done
         ES
      fi
      ;;
   3)
      S=M3
      SC
      if [[ $cur == enter ]]; then
         R
         # Dotfiles
         sudo apt install neovim tmux htop fzf git wget curl bash-completion -y
         cp -vrf config-files/.* $HOME
         cp -vrf config-files/* $HOME
         dconf load -f / <./settings.dconf
         fc-cache -f
         ES
      fi
      ;;
   4)
      S=M4
      SC
      if [[ $cur == enter ]]; then
         R
         # Flatpak
         sudo apt install flatpak gnome-software-plugin-flatpak
         sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
         flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
         ES
      fi
      ;;
   5)
      S=M5
      SC
      if [[ $cur == enter ]]; then
         R
         exit 0
      fi
      ;;
   esac
   POS
done
