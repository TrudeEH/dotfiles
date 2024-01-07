source ./p.sh
if [[ $(p c jan) == 0 ]]; then
    echo "Jan is installed. Launch it from the app menu."
else
    p i jan
fi
