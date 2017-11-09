#!/bin/sh
# i3 startup script

# Wait a while
sleep 1s;

# Set gb keyboard
setxkbmap gb

# Screensaver
xscreensaver -nosplash &

# Restore wallpaper
nitrogen --restore &

# Enable touchpad tapping and typing mod
# (synclient TapButton1=1 TapButton2=2 TapButton3=3; syndaemon -t -k -i 2 -d) &

# Reverse scrolling
# synclient VertScrollDelta=-111
# synclient HorizScrollDelta=-111

# Start an lxterminal
lxterminal &

# Screen brightness tool
(killall redshift-gtk; redshift-gtk -l 51.61:-0.32) &

# Transmission client
transmission-qt &

# Keepassx
keepassx &

# Dropbox
(sleep 10s && ~/.dropbox-dist/dropboxd) &

# Python power management script
# python ~/code/scripts/power_man.py &
#python ~/code/scripts/power_man.py >> ~/code/scripts/power_man.log 2>&1  & # debugging
