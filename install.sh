#! /bin/zsh

source ./scripts/color.sh
source ./scripts/symlink-files.sh
source ./home/.zshrc

# Link configs
echo -e "${GREEN}[+] Symlinking dotfiles...${ENDCOLOR}"
symlink_files "./home" $HOME

echo -n "Run MacOS config script? This will overwrite the system dock. (y/n): "
read runConfig
if [[ $runConfig == 'y' ]]; then
    echo -e "${GREEN}[+] Configuring MacOS...${ENDCOLOR}"
    bash ./darwinSettings.sh
fi

# Restore Brew Installs
echo -e "${GREEN}[+] Restoring Brew from BrewFile...${ENDCOLOR}"
p b BrewFile

# Install Oh-My-ZSH
echo -e "${GREEN}[+] Installing Oh-My-ZSH...${ENDCOLOR}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Update MacOS
echo -e "${GREEN}[+] Updating MacOS...${ENDCOLOR}"
echo -e "${GREEN}[I] THE DEVICE WILL RESTART IF NECESSARY.${ENDCOLOR}"
sudo softwareupdate -iaR

echo -e "${GREEN}${BOLD}[i] All done.${ENDCOLOR}"
