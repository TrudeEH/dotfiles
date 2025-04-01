#! /bin/bash

YELLOW="\e[33m"
ENDCOLOR="\e[0m"

echo -e "\n${YELLOW}Downloading APT dependencies...${ENDCOLOR}\n"
sudo apt install build-essential git -y
sudo apt build-dep linux -y

echo -e "\n${YELLOW}Downloading kernel source...${ENDCOLOR}\n"
mkdir linux-parent && cd linux-parent
git clone --depth 1 https://github.com/torvalds/linux
cd linux

cp /boot/config-$(uname -r) .config   # Copy current kernel config
make nconfig                          # Edit the current kernel configuration
diff /boot/config-$(uname -r) .config # Check your changes

# Do not include debugging symbols. Alternatively, use `strip` to remove them. (these configs are working as of 6.14)
scripts/config --undefine GDB_SCRIPTS
scripts/config --undefine DEBUG_INFO
scripts/config --undefine DEBUG_INFO_SPLIT
scripts/config --undefine DEBUG_INFO_REDUCED
scripts/config --undefine DEBUG_INFO_COMPRESSED
scripts/config --set-val DEBUG_INFO_NONE y
scripts/config --set-val DEBUG_INFO_DWARF5 n
scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT

echo -e "\n${YELLOW}Compiling the kernel...${ENDCOLOR}\n"
make -j$(nproc) deb-pkg LOCALVERSION=-custom

echo -e "\n${YELLOW}Installing the generated dpkg packages...${ENDCOLOR}\n"
sudo dpkg -i ../linux-headers*-custom*.deb
sudo dpkg -i ../linux-image*-custom*.deb

echo -e "\n${YELLOW}Cleaning up...${ENDCOLOR}\n"
cd ../..
rm -rf linux-parent

dpkg --list | grep linux-image
