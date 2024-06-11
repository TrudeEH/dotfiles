#! /bin/sh
BACKTITLE="Trude's FreeBSD Toolkit"

dialog --erase-on-exit \
       --backtitle "$BACKTITLE" \
       --checklist "Use the arrow keys and SPACE to select, then press ENTER." 30 100 5 \
        "1" "Update FreeBSD" "on"\
        "2" "Install/Update Dotfiles (DWM)" "on"\
        "3" "Add Programs" "off" 2> main.tmp
main_menu=$( cat main.tmp )
rm main.tmp
mkdir logs

rm logs/compile.log
rm logs/compile.err.log
compile() {
  cd programs/$1
  doas rm -rf config.h
  doas make clean install >> $HOME/dotfiles/logs/compile.log 2>> $HOME/dotfiles/logs/compile.err.log
  cd ../..
}

for selection in $main_menu; do
  if [ "$selection" = "1" ]; then
    # --- UPDATE FREEBSD ---

    showUpdate() {
      # showUpdate global_per s1 s2 s3 s4
      dialog --backtitle "$BACKTITLE" --title "Update FreeBSD and Packages" \
	       --mixedgauge "Updating..." \
	       0 0 $1 \
         "Fetch FreeBSD updates" "$2" \
         "Update FreeBSD" "$3" \
         "Fetch package updates" "$4" \
         "Update packages" "$5"
    }

    showUpdate 0 7 4 4 4

    doas freebsd-update fetch > logs/update.log
    showUpdate 20 5 7 4 4

    doas freebsd-update install >> logs/update.log
    showUpdate 50 5 5 7 4

    doas pkg update >> logs/update.log
    showUpdate 70 5 5 5 7

    doas pkg upgrade -y >> logs/update.log
    showUpdate 100 5 5 5 5
  fi

  if [ "$selection" = "2" ]; then
    # --- INSTALL DOTFILES ---

    showDotfiles() {
      dialog --backtitle "$BACKTITLE" --title "Install Trude's Dotfiles" \
        --mixedgauge "Installing dotfiles..." \
        0 0 $1 \
        "Install Xorg" "$2" \
        "Install GPU Drivers" "$3" \
        "Install Dependencies" "$4" \
        "Install Utilities" "$5" \
        "Compile Programs" "$6" \
        "Copy Dotfiles to \$HOME" "$7"
    }

    showDotfiles 0 7 4 4 4 4 4

    doas pkg install -y xorg > logs/dotfiles.log
    doas sysrc dbus_enable=YES #Enable DBUS, needed for Xorg
    showDotfiles 30 5 7 4 4 4 4

    # TODO: Menu to allow the user to choose AMD, NVIDIA or INTEL driver. Defaults to Intel.
    doas pkg install -y drm-kmod >> logs/dotfiles.log
    doas pw groupmod video -m $USER
    doas sysrc kld_list+=i915kms
    showDotfiles 50 5 5 7 4 4 4

    # ST DMENU DWM...
    doas pkg install -y x11/libX11 x11-fonts/libXft x11/libXinerama x11/libXext devel/pkgconf print/freetype2 x11-fonts/fontconfig >> logs/dotfiles.log
    # SURF
    doas pkg install -y ftp/curl www/webkit2-gtk3 devel/libsoup security/gcr accessibility/at-spi2-core graphics/cairo graphics/gdk-pixbuf2 devel/glib20 devel/gettext-runtime x11-toolkits/gtk30 x11-toolkits/pango >> logs/dotfiles.log
    showDotfiles 80 5 5 5 7 4 4

    doas pkg install -y feh scrot >> logs/dotfiles.log
    showDotfiles 90 5 5 5 5 7 4

    for program in "dwm" "dmenu" "slock" "slstatus" "st" "tabbed" "surf"; do
      compile $program
    done
    showDotfiles 98 5 5 5 5 5 7

    cp -vrf $HOME/dotfiles/dotfiles/.[!.]* $HOME >> logs/dotfiles.log
    showDotfiles 100 5 5 5 5 5 5

  fi
done


# pkg install libva-intel-driver mesa-libs mesa-dri # IF NEEDED ONLY (stutter and tearing for intel)

