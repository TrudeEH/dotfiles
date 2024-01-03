#! /bin/bash

sudo
echo "------------------- TCP --------------------"
sudo ss -tlpn
echo "------------------- UDP --------------------"
sudo ss -ulpn
