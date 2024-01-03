#! /bin/bash

ollama=$(pacman -Q ollama)
if [[ -n "$ollama" ]]; then
    kgx -e "ollama serve"
    sleep 1
    kgx -e "ollama run codellama"
else
    kgx -e "sudo paru -S ollama; echo 'Run the script again...'"
fi
