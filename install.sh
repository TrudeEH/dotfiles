#! /bin/sh

# export LOG_LEVEL="$LOG_DEBUG"

admin() {
  su -m root -c "$*"
}

echo "Updating user packages..."
admin pkg update & pkg upgrade

