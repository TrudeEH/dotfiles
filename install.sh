#! /bin/sh

while true; do
  CHOICE=$(dialog --backtitle "Trude's FreeBSD Toolkit" \
    --title "Main Menu" \
    --menu "Select your action:" 15 50 5 \
      "1" "Update FreeBSD" \
      "2" "Disk Usage" \
      "3" "Network Status" \
      "4" "Exit")

  case "$CHOICE" in
    1)
      # --- UPDATE FREEBSD ---
      dialog --gauge "Updating FreeBSD..." 10 50 0  # Initial gauge

      { # Subshell to capture output without displaying it
        doas freebsd-update fetch install
        doas pkg update
        doas pkg upgrade -y
      } 2>&1 | while read -r line; do
        # Roughly estimate progress based on keywords
        case "$line" in
          *fetch*) PERCENTAGE=20 ;;
          *install*) PERCENTAGE=50 ;;
          *upgrad*) PERCENTAGE=80 ;;
          *complete*) PERCENTAGE=100 ;;
          *) PERCENTAGE=$((PERCENTAGE + 1)) ;; # Small increments otherwise
        esac
        dialog --gauge "$line" 10 50 $PERCENTAGE
      done

      dialog --msgbox "Update complete!" 5 30
      ;;
    2)
      dialog --textbox /proc/mounts 20 60
      ;;
    3)
      dialog --msgbox "$(ip addr | grep 'state UP')" 15 50
      ;;
    4)
      break
      ;;
  esac
done

echo "Installing Desktop..."

# XORG on Intel GPU
doas pkg install xorg drm-kmod
doas pw groupmod video -m trude
doas sysrc kld_list+=i915kms

# pkg install libva-intel-driver mesa-libs mesa-dri # IF NEEDED ONLY


# ST / DWM / DMENU ...
doas pkg install x11/libX11 x11-fonts/libXft x11/libXinerama x11/libXext devel/pkgconf print/freetype2 x11-fonts/fontconfig

# SURF
doas pkg install ftp/curl www/webkit2-gtk3 devel/libsoup security/gcr accessibility/at-spi2-core graphics/cairo graphics/gdk-pixbuf2 devel/glib20 devel/gettext-runtime x11-toolkits/gtk30 x11-toolkits/pango

# Utilities
doas pkg install feh scrot

compile() {
  cd programs/$1
  doas rm -rf config.h
  doas make clean install
  cd ../..
}

# Compile programs
for program in "dwm" "dmenu" "slock" "slstatus" "st" "tabbed" "surf"; do
  compile $program
done

doas sysrc dbus_enable=YES #Enable DBUS, needed for Xorg


# Copy dotfiles to $HOME
cp -vrf $HOME/dotfiles/dotfiles/.* $HOME

