#! /bin/zsh

source ./scripts/p.sh
source ./scripts/color.sh

dist=$(d)

if [ $dist != 3 ]; then
    echo -e "${RED}[E] Run linux.sh for Linux instead.${ENDCOLOR}"
    return 1
fi

# Copy configs
echo -e "${GREEN}[+] Configuring system...${ENDCOLOR}"
cp -rf homeConfigs/.* ~

# Disable dock delay
echo -e "${GREEN}[+] Disabling dock autohide delay...${ENDCOLOR}"
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide -int 1
#defaults write com.apple.dock autohide-time-modifier -int 0 #Disable animation
killall Dock

# Install brew
echo -e "${GREEN}[+] Installing homebrew...${ENDCOLOR}"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Enable brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Nerd Font
if p c font-jetbrains-mono-nerd-font &>/dev/null; then
    echo -e "${GREEN}[i] JetBrains font is installed.${ENDCOLOR}"
else
    echo -e "${GREEN}[+] Installing JetBrains font.${ENDCOLOR}"
    p i font-jetbrains-mono-nerd-font
    echo -e "${GREEN}[i] JetBrains font installed.${ENDCOLOR}"
fi

echo -e "${GREEN}${BOLD}[i] All done.${ENDCOLOR}"
