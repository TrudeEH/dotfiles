#! /bin/zsh

source ./scripts/p.sh
source ./scripts/color.sh

dist=$(d)

if [ $dist != 3 ]; then
    echo -e "${RED}[E] Run linux.sh for Linux instead.${ENDCOLOR}"
    return 1
fi

# Ask Y/n
function ask() {
    read -p "$1 (Y/n): " resp
    if [ -z "$resp" ]; then
        response_lc="y" # empty is Yes
    else
        response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
    fi

    [ "$response_lc" = "y" ]
}

# Copy configs
echo -e "${GREEN}[+] Configuring system...${ENDCOLOR}"
cp -rf homeConfigs/.* ~

# Install brew
echo -e "${GREEN}[+] Installing homebrew...${ENDCOLOR}"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Enable brew
eval "$(/opt/homebrew/bin/brew shellenv)"

echo -e "${GREEN}${BOLD}[i] All done.${ENDCOLOR}"
