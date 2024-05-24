curl -sS https://minecraft-linux.github.io/pkg/deb/pubkey.gpg | sudo tee -a /etc/apt/trusted.gpg.d/minecraft-linux-pkg.asc
echo "deb [arch=amd64,arm64,armhf] https://minecraft-linux.github.io/pkg/deb bookworm-nightly main" | sudo tee /etc/apt/sources.list.d/minecraft-linux-pkg.list
sudo apt install mcpelauncher-manifest mcpelauncher-ui-manifest msa-manifest
