echo "PUBLIC IP:"
wget -qO - https://api.ipify.org
echo
echo

# echo "TOR PUBLIC IP:"
# torsocks wget -qO - https://api.ipify.org; echo
# echo

echo "OPEN PORTS:"
sudo ss -tupln
