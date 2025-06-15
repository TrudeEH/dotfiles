#! /bin/sh

sudo apt install miniupnpc
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Nextcloud
upnpc -a $LOCAL_IP 80 80 tcp
upnpc -a $LOCAL_IP 8080 8080 tcp
upnpc -a $LOCAL_IP 8443 8443 tcp
upnpc -a $LOCAL_IP 443 443 tcp
upnpc -a $LOCAL_IP 3478 3478 tcp
upnpc -a $LOCAL_IP 3478 3478 udp

# SSH
upnpc -a $LOCAL_IP 22 22 tcp

upnpc -l
