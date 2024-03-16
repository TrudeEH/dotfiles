#! /bin/zsh

source ./scripts/color.sh

# Copy configs
echo -e "${GREEN}[+] Configuring system...${ENDCOLOR}"
cp -rf ./homeConfigs/.* ~

echo "Run MacOS config script? This will overwrite the system dock."
read runConfig
if [[ $runConfig == 'y' ]]; then
    echo "Running config.sh..."
    bash ./config.sh
fi

# Install Oh-My-ZSH
echo -e "${GREEN}[+] Installing Oh-My-ZSH...${ENDCOLOR}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install fonts
echo -e "${GREEN}[+] Installing fonts...${ENDCOLOR}"
cp ./fonts/* ~/Library/Fonts

# Update MacOS
echo -e "${GREEN}[+] Updating MacOS...${ENDCOLOR}"
echo -e "${GREEN}[I] THE DEVICE WILL RESTART IF NECESSARY.${ENDCOLOR}"
sudo softwareupdate -iaR

echo -e "${GREEN}${BOLD}[i] All done.${ENDCOLOR}"
