#!/bin/bash

# List all installed apps
all_apps=(/Applications/*)

# Loop through each app
for app in "${all_apps[@]}"; do
  # Extract the app name without the extension (if any)
  app_name="${app##*/}"
  app_name="${app_name%.*}"  # Removes everything after the last dot

  # Check if the app name exists in a brew cask
  brew search $app_name &> /dev/null
  if [ $? -eq 0 ]; then
    echo "Found $app_name in Homebrew. Installing..."
    brew install --cask --force "$app_name"
  else
    echo "$app_name not found in Homebrew."
  fi
done

echo "All checks completed."
