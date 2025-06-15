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

if ! command -v whiptail >/dev/null 2>&1; then
  echo "${YELLOW}Installing whiptail...${NC}"
  sudo apt install -y whiptail
fi

NC_DATA=$(whiptail --title "Nextcloud Data Directory" --inputbox "Enter the directory for Nextcloud data:" 10 60 "$NC_data" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus -ne 0 ] || [ -z "$NC_DATA" ]; then
  echo "${RED}User canceled. Exiting...${NC}"
  exit 1
fi

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

echo "${YELLOW}Installing Nextcloud...${NC}"
docker run -d \
  --init \
  --sig-proxy=false \
  --name nextcloud-aio-mastercontainer \
  --restart always \
  --publish 80:80 \
  --publish 8080:8080 \
  --publish 8443:8443 \
  --env NEXTCLOUD_DATADIR="$NC_DATA" \
  --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  ghcr.io/nextcloud-releases/all-in-one:latest

echo "${YELLOW}Installing PiHole...${NC}"
docker run -d \
  --name pihole \
  -p "53:53/tcp" \
  -p "53:53/udp" \
  -p "6000:80/tcp" \
  -p "6001:443/tcp" \
  -e "TZ=Europe/Lisbon" \
  -e "FTLCONF_dns_listeningMode=all" \
  -v "~/etc-pihole:/etc/pihole" \
  --cap-add NET_ADMIN \
  --cap-add SYS_TIME \
  --cap-add SYS_NICE \
  --restart unless-stopped \
  pihole/pihole:latest

LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "${CYAN}Nextcloud AIO @ https://$LOCAL_IP:8080${NC}"
echo "${CYAN}Nextcloud @ https://$LOCAL_IP${NC}"
echo "${CYAN}PiHole Password:"
docker logs pihole | grep "random password"
echo "PiHole @ https://$LOCAL_IP:6001/admin/login${NC}"
