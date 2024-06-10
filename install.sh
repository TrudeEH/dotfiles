#! /bin/sh

echo "Updating user packages..."
doas pkg update
doas pkg upgrade

echo "Installing Desktop..."

# ST / DWM / DMENU ...
doas pkg install xorg x11/libX11 x11-fonts/libXft x11/libXinerama x11/libXext devel/pkgconf print/freetype2 x11-fonts/fontconfig

# SURF
doas pkg install ftp/curl www/webkit2-gtk3 devel/libsoup security/gcr accessibility/at-spi2-core graphics/cairo graphics/gdk-pixbuf2 devel/glib20 devel/gettext-runtime x11-toolkits/gtk30 x11-toolkits/pango

compile() {
  cd programs/$1
  doas rm -rf config.h
  doas make clean install
  cd ../..
}

# Compile programs
for program in "dwm" "dmenu" "slock" "slstatus" "st" "tabbed" "surf" "herbe"; do
  compile $program
done


# Copy dotfiles to $HOME
cp -vrf dotfiles/.* $HOME

