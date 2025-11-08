#!/bin/bash

# This script is executed by i3 on startup.

# Terminate already running instances of programs
killall -q picom
killall -q dunst
killall -q nitrogen
killall -q nm-applet
killall -q blueman-applet
killall -q flameshot
killall -q conky
# Add other apps you want to ensure are killed before restarting

# Wait until the processes have been shut down
while pgrep -u $UID -x picom >/dev/null; do sleep 1; done
# Add other 'while' loops if you need to wait for specific apps

# Set screen layout with xrandr (uncomment and customize if needed)
# xrandr --output eDP1 --primary --mode 1920x1080 --pos 0x0 --rotate normal &

# Set wallpaper
nitrogen --restore &

# Launch compositor
picom -b &

# Launch notification daemon
dunst &

# Launch applets in the background
nm-applet &
blueman-applet &
flameshot &

# Launch password manager
keepassxc &

# Launch system monitor
conky --config=/usr/share/conky/conky_theme &

# Start PulseAudio and applet
start-pulseaudio-x11 &
pa-applet &

# Set keyboard numlock state
/usr/bin/numlockx on &

# Start screen temperature utility
/usr/bin/redshift-gtk &

# Start screen locker daemon with 5s idle delay (no delay on suspend)
xset s 900 5 &
xss-lock -- sh -c 'sleep 5; exec i3lock -n --ignore-empty-password --color=444444' &

echo "Autostart script finished."