#!/bin/zsh

RED="\e[31m"
GREEN="\e[32m"
GRAY="\e[90m"
BOLD="\e[1m"
ENDCOLOR="\e[0m"

# List all installed apps
all_apps=(/Applications/*)
homebrew_apps=$(brew list --casks)
not_found_list=()
brew_available=()

for app in "${all_apps[@]}"; do
  # Extract the name of the app without the path
  app_name=$(basename "$app")
  app_name="${app_name%.*}"
  app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')
  app_name=$(echo "$app_name" | tr " " -)

  if [[ $app_name == "utilities" ]]; then continue; fi

  echo -ne "${GRAY}Checking app: ${ENDCOLOR}${BOLD}$app_name${ENDCOLOR}${GRAY}...${ENDCOLOR}"
  # Check if app is in homebrew list, if not print its name to terminal
  echo $homebrew_apps | grep -wq $app_name
  if [[ $? == 0 ]]; then
    echo -e " ${GREEN}TRUE${ENDCOLOR}"
  else
    echo -e " ${RED}FALSE${ENDCOLOR}"
    not_found_list+=($app_name)

    # Check if app is available with brew
    brew search --cask -q $app_name &>/dev/null | grep -x $app_name &>/dev/null
    if [ $? -eq 0 ]; then
      brew_available+=($app_name)
    fi
  fi
done

echo
echo "-------------------------------------"
echo
echo -e "${BOLD}Not installed with brew: ${ENDCOLOR}$not_found_list"
echo
echo -e "${BOLD}Available in brew: ${ENDCOLOR}$brew_available"
echo
if [[ ! -z $brew_available ]]; then
  echo "-------------------------------------"
  echo
  echo -n "Replace the existing (available) apps with brew casks? (y/n): "
  read replaceApps
  if [[ $replaceApps == "y" ]]; then
    for app in "${brew_available[@]}"; do
      brew install --cask --force $app
    done
  fi
fi
