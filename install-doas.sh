#! /bin/sh

# If using another user, switch trude to wheel or that user's name.

echo "RUN THIS SCRIPT AS ROOT: (su -)"
pkg install doas
echo "permit nopass keepenv :trude" > /usr/local/etc/doas.conf
echo "permit nopass keepenv root as root" >> /usr/local/etc/doas.conf
