#! /bin/bash

sudo apt install flatpak || {
  echo "Failed to install flatpak. Try: \"sudo apt update\" and run the script again."
  exit 1
}

flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || {
  echo "Failed to add flathub remote."
  exit 1
}

flatpak install flathub com.valvesoftware.Steam || {
  echo "Failed to install Steam."
  exit 1
}

flatpak install flathub com.github.Anuken.Mindustry || {
  echo "Failed to install Mindustry."
  exit 1
}

echo
echo "Done."
echo
