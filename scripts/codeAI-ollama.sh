#! /bin/bash

source ./p.sh
if [[ $(p c ollama) == 0 ]]; then
    kgx -e "ollama serve"
    sleep 1
    kgx -e "ollama run codellama"
else
    p i ollama
    echo
    echo 'Run the script again...'
fi
