#! /bin/sh

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
MAGENTA="\e[35m"
CYAN="\e[36m"
BOLD="\e[1m"
NC="\e[0m"

trap 'printf "${RED}install.sh interrupted.${NC}"; exit 1' INT TERM

../scripts/update

echo "${YELLOW}Before starting the script, mount your storage device for the server @ /server, then press ENTER to continue. If you wish to use the /root drive, skip this step.${NC}"
SRV_DATA="/server" # Change on the compose file as well!
read

echo "${YELLOW}Installing Docker...${NC}"
# Add Docker's official GPG key
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group (to remove the need to use sudo)
sudo usermod -aG docker $USER

echo "${YELLOW}Running compose...${NC}"
sudo mkdir $SRV_DATA
cd $SRV_DATA
sudo chown -R 1000:1000 $SRV_DATA
mkdir ncdata
docker compose up -d --remove-orphans

LOCAL_IP=$(hostname -I | awk '{print $1}')
echo
echo "${CYAN}Ports:"
echo "Nextcloud: http://$LOCAL_IP:11000"
echo "Nextcloud AIO: https://$LOCAL_IP:8080"
echo "Gitea: http://$LOCAL_IP:3001"
echo "Nginx Proxy Manager: https://$LOCAL_IP:81"
echo "${NC}"
