#!/bin/bash

# Dependencies
export NIXPKGS_ALLOW_UNFREE=1
if [ $(pwd) != "$HOME/dotfiles" ]; then
   cd $HOME
   git clone https://github.com/TrudeEH/dotfiles --depth 1
   cd dotfiles
fi

if ! nix --version &>/dev/null; then
   echo "[E] Nix not found."
   echo "[+] Installing the Nix package manager..."
   sh <(curl -L https://nixos.org/nix/install)
   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   echo "[I] Installed Nix."
fi

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
   for each in $(seq 1 11); do
      $E "   \xE2\x94\x82                                          \xE2\x94\x82"
   done
   MARK
   TPUT 1 5
   $E "            Trude's Toolkit               "
   UNMARK
}
i=0
FOOT() {
   MARK
   TPUT 11 5
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
   TPUT 4 11
   $e "Set up Generic System"
}
M1() {
   TPUT 5 11
   $e "Set up NixOS"
}
M2() {
   TPUT 6 11
   $e "Set up macOS"
}
M3() {
   TPUT 8 11
   $e "EXIT"
}
LM=3
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
         # Install Home-manager
         nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
         nix-channel --update
         nix-shell '<home-manager>' -A install

         # Apply config
         mkdir -p $HOME/.config/home-manager
         rm $HOME/.config/home-manager/home.nix
         cp ./nix/home.nix $HOME/.config/home-manager/home.nix

         home-manager -b backup switch
         ES
      fi
      ;;
   1)
      S=M1
      SC
      if [[ $cur == enter ]]; then
         R
         # Dotfiles for NixOS
         sudo cp -rf ./nix/nixos/* /etc/nixos/
         sudo cp -f ./nix/home.nix /etc/nixos/
         sudo nixos-rebuild switch --flake /etc/nixos#default
         ES
      fi
      ;;
   2)
      S=M2
      SC
      if [[ $cur == enter ]]; then
         R
         mkdir -p ~/.config/nix-darwin/
         cp -rf ./nix/macOS/* ~/.config/nix-darwin/
         cp -f ./nix/home.nix ~/.config/nix-darwin/
         nix run nix-darwin -- switch --flake ~/.config/nix-darwin
         ES
      fi
      ;;
   3)
      S=M3
      SC
      if [[ $cur == enter ]]; then
         R
         exit 0
      fi
      ;;
   esac
   POS
done
