#! /bin/zsh

source ./scripts/color.sh

# Copy configs
echo -e "${GREEN}[+] Configuring system...${ENDCOLOR}"
cp -rf ./homeConfigs/.* ~

# Disable dock delay
echo -e "${GREEN}[+] Disabling dock autohide delay...${ENDCOLOR}"
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide -int 1
#defaults write com.apple.dock autohide-time-modifier -int 0 #Disable animation
killall Dock

# Hide dotfiles folder
echo -e "${GREEN}[+] Hiding dotfiles folder from finder...${ENDCOLOR}"
chflags hidden ~/dotfiles
# Unhide: chflags nohidden /path/to/unhide/

# Install Oh-My-ZSH
echo -e "${GREEN}[+] Installing Oh-My-ZSH...${ENDCOLOR}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install fonts
echo -e "${GREEN}[+] Installing fonts...${ENDCOLOR}"
cp ./fonts/* ~/Library/Fonts

# Update MacOS
echo -e "${GREEN}[+] Updating MacOS...${ENDCOLOR}"
sudo softwareupdate -ia

echo -e "${GREEN}${BOLD}[i] All done.${ENDCOLOR}"
say "All done."
