slstatus &
feh --bg-scale "/home/trude/dotfiles/bg2.png" &
xrdb ~/.Xresources
dunst &
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
picom &

export XDG_SESSION_TYPE=???
export XDG_SESSION_DESKTOP=???
export XDG_CURRENT_DESKTOP=???

dbus-launch --exit-with-session dwm
