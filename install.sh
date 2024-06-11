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

for selection in $main_menu; do
  if [ "$selection" = "1" ]; then
  # --- UPDATE FREEBSD ---

  showUpdate() {
    # showUpdate global_per s1 s2 s3 s4
    dialog --backtitle "$BACKTITLE" --title "Updating FreeBSD and Packages" \
	       --mixedgauge "Updating..." \
	       0 0 $1 \
         "Fetch FreeBSD updates" "$2" \
         "Update FreeBSD" "$3" \
         "Fetch package updates" "$4" \
         "Update packages" "$5"
    }

    showUpdate 0 7 0 0 0

    doas freebsd-update fetch > install.log
    showUpdate 20 5 7 0 0

    doas freebsd-update install >> install.log
    showUpdate 50 5 5 7 0

    doas pkg update >> install.log
    showUpdate 70 5 5 5 7

    doas pkg upgrade -y >> install.log
    showUpdate 100 5 5 5 5
  fi
done

#if [[ ${main_menu[@]} =~ 2 ]]; then
  #--- INSTALL DOTFILES ---

#fi

# XORG on Intel GPU

#doas pkg install xorg drm-kmod
#doas pw groupmod video -m trude
#doas sysrc kld_list+=i915kms

# pkg install libva-intel-driver mesa-libs mesa-dri # IF NEEDED ONLY


# ST / DWM / DMENU ...
#doas pkg install x11/libX11 x11-fonts/libXft x11/libXinerama x11/libXext devel/pkgconf print/freetype2 x11-fonts/fontconfig

# SURF
#doas pkg install ftp/curl www/webkit2-gtk3 devel/libsoup security/gcr accessibility/at-spi2-core graphics/cairo graphics/gdk-pixbuf2 devel/glib20 devel/gettext-runtime x11-toolkits/gtk30 x11-toolkits/pango

# Utilities
#doas pkg install feh scrot

#compile() {
#  cd programs/$1
#  doas rm -rf config.h
#  doas make clean install
#  cd ../..
#}

# Compile programs
#for program in "dwm" "dmenu" "slock" "slstatus" "st" "tabbed" "surf"; do
 # compile $program
#done

#doas sysrc dbus_enable=YES #Enable DBUS, needed for Xorg


# Copy dotfiles to $HOME
#cp -vrf $HOME/dotfiles/dotfiles/.* $HOME

