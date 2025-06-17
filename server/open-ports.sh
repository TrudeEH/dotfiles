#! /bin/sh

sudo apt install miniupnpc
LOCAL_IP=$(hostname -I | awk '{print $1}')

# NGINX PROXY MANAGER
upnpc -a $LOCAL_IP 80 80 tcp
upnpc -a $LOCAL_IP 443 443 tcp
#upnpc -a $LOCAL_IP 81 81 tcp # Admin UI

# NEXTCLOUD
upnpc -a $LOCAL_IP 11000 11000 tcp
upnpc -a $LOCAL_IP 8080 8080 tcp # AIO
upnpc -a $LOCAL_IP 3478 3478 tcp # talk
upnpc -a $LOCAL_IP 3478 3478 udp # talk

# GIT
upnpc -a $LOCAL_IP 3001 3001 tcp

# SSH
upnpc -a $LOCAL_IP 22 22 tcp

upnpc -l
