#! /bin/sh

# export LOG_LEVEL="$LOG_DEBUG"

echo "Updating user packages..."
doas pkg update
doas pkg upgrade
