#!/bin/bash

# Function to symlink all files in one directory, to another.
# Example use-case: Symlink all files in .dotfiles to the $HOME directory.
# Usage example: symlink_files $source $destination

symlink_files() {
    # Check if source and destination directories exist
    if [ ! -d "$1" ] || [ ! -d "$2" ]; then
        echo "Error: Source or destination directory does not exist!"
        return 1
    fi

    # Loop through each file in the source directory (including hidden)
    for file in $(find "$1" -type f -print); do
        filePath=$(realpath $file)
        ln -s "$filePath" "$2/$(basename "$file")"
        echo "Linked: $file to $2/$(basename "$file")"
    done
}
