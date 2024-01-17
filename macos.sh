#! /bin/bash

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to path
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') > /Users/trude/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
echo 'PATH="/usr/local/bin:$PATH"' > ~/.bash_profile

# Install VScode
brew install visual-studio-code
