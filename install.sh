#! /bin/sh

# export LOG_LEVEL="$LOG_DEBUG"

admin() {
  su - root -c "$*"
}

echo "Updating user packages..."
admin pkg update & pkg upgrade

