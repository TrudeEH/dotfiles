#! /bin/bash

source scripts/p.sh

# ============== CONFIG ==============

# Install Dependency: stow
p i stow

# Link dotfile home to $HOME
echo -e "[+] Symlinking dotfiles..."
stow -v -t $HOME home --adopt

# Install Oh-My-ZSH
echo -e "${GREEN}[+] Installing Oh-My-ZSH...${ENDCOLOR}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo -e "${GREEN}${BOLD}[i] All done.${ENDCOLOR}"
