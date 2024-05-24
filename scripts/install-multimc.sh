# Install multimc
sudo nala update
sudo nala install libqt5core5a libqt5network5 libqt5gui5
wget https://files.multimc.org/downloads/multimc_1.6-1.deb
sudo nala install ./multimc_1.6-1.deb
rm multimc_1.6-1.deb

# Install java
sudo mkdir -p /etc/apt/keyrings
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo nala update
sudo nala install temurin-8-jdk temurin-21-jdk temurin-17-jdk
