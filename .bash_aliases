# Aliases and custom functions

## General
alias new='aptitude search ~U'
alias upgrade="sudo aptitude update && sudo aptitude safe-upgrade"
alias apv='aptitude versions'
alias proses='ps auxf | less'
alias ll="ls -haltr"
alias tma="tmux attach -d"
alias dirs="dirs -v"
alias torfox="firefox-esr -P torfox -no-remote &"
alias defaultfox="firefox-esr -P default -no-remote &"
alias tailf="tail -f"

## Aliases
### Awk aliases for getting n-th column
alias c1="awk '{print \$1}'"
alias c2="awk '{print \$2}'"
alias c3="awk '{print \$3}'"
alias c4="awk '{print \$4}'"
alias c5="awk '{print \$5}'"
alias c6="awk '{print \$6}'"
alias c7="awk '{print \$7}'"
alias c8="awk '{print \$8}'"
alias c9="awk '{print \$9}'"

## Functions

mount_remotes() {
    fusermount -u ~/mnt/mini_server_downloads
    fusermount -u ~/cloud_encfs
    fusermount -u ~/Dropbox
    sshfs -o reconnect,follow_symlinks  mini_server:Downloads/ \
    ~/mnt/mini_server_downloads &&
    sshfs -o reconnect mini_server:cloud_encfs/ ~/cloud_encfs/ &&
    sshfs -o reconnect mini_server:Dropbox/ ~/Dropbox/
}

xclipper() {
    echo "Starting xclipper..."
    while [ 1 ]
    do
        nc -lp 2224 | /usr/bin/xclip -i -f -selection primary | \
            /usr/bin/xclip -i -selection clipboard;
    done
}

start_xclipper() {
    if ! nc -z localhost 2224
    then
        xclipper &
    fi
}


## Chromebook specific stuff
# export ENCFS6_CONFIG=/home/nasef/.encfs6.xml
# export JAVA_HOME="/home/nasef/extra/apps/jdk1.8.0_172"
# export PATH=/home/nasef/extra/apps/apache-maven-3.5.3/bin:$PATH
# 
# mount_encfs_sd() {
# 	if [ ! -e ~/extra/apps ]
#     then
#         umount_encfs_sd
# 		echo "Mounting encfs dir on SD card..."
# 		encfs /media/removable/SD\ Card/.extra/ ~/extra
#     fi
# }
# 
# umount_encfs_sd() {
#     echo "Attempting unmount of encfs on SD card..."
#     fusermount -u ~/extra &> /dev/null
#     
# }
# 
# mount_remotes() {
#     fusermount -u ~/mnt/mini_server_downloads
#     fusermount -u ~/cloud_encfs
#     fusermount -u ~/Dropbox
#     sshfs -o reconnect,follow_symlinks  mini_server:Downloads/ \
#     ~/mnt/mini_server_downloads &&
#     sshfs -o reconnect mini_server:cloud_encfs/ ~/cloud_encfs/
#     sshfs -o reconnect mini_server:Dropbox/ ~/Dropbox/
# }


## Old stuff
# Other
# alias scc="screen -dR"
# alias takenote='~/code/scripts/pytakenote.py'
# alias big='du -hs ~/* | sort -nr | head'
# alias bigr='du -hs /* | sort -nr | head'
# alias specstart="cp -v ~/.xinitrc_spectrwm ~/.xinitrc; startx"
# alias lxdestart="cp -v ~/.xinitrc_lxde ~/.xinitrc; startx"
# alias i3start="cp -v ~/.xinitrc_i3 ~/.xinitrc; startx"
# alias netcons="sudo watch -n10 'netstat -tup'"


# Pi/Server
#alias chksshd='grep "sshd" /var/log/auth.log | less'
#alias startspect='cp -fv ~/.spectrwm_xinitrc ~/.xinitrc; startx; rm -v .xinitrc'
#alias startob='cp -fv ~/.ob_xinitrc ~/.xinitrc; startx; rm -v .xinitrc '
#alias temp='vcgencmd measure_temp'
#alias rbk='sudo ionice -c3 nice -n19 sh ~/.scripts/backup.sh'
#alias omx='omxplayer -o  hdmi -r '
#alias fwlogr="tail -f /var/log/messages | grep -i 'iptables' --line-buffered | grep -Pi 'SRC\=([\d\.]+)' --color=always --line-buffered |  grep -Pi 'dpt\=(\d+)' --color=always --line-buffered | grep -P '\s\d{2}\:\d{2}\:\d{2}\s' --color=always --line-buffered "
#alias fwlogs="cat /var/log/messages | grep -i 'iptables'  | grep -Pi 'SRC\=([\d\.]+)' --color=always |  grep -Pi 'dpt\=(\d+)' --color=always | grep -P '\s\d{2}\:\d{2}\:\d{2}\s' --color=always |    less -R "
#alias ckssh='grep -i "sshd" /var/log/auth.log  | grep -P "\d+\.\d+\.\d+\.\d+" --color=always | less -R'
#alias transdaemon='transmission-daemon -e /mnt/data1/transmission_daemon.log --log-info


# Old
# alias low-power="su -c 'cpufreq-set -c 0 -g powersave && cpufreq-set -c 1 -g powersave'"
# alias norm-power="su -c 'cpufreq-set -c 0 -g ondemand && cpufreq-set -c 1 -g ondemand'"
# alias slowcon="su -c 'wondershaper wlan0 160 160'"
# alias fastcon="su -c 'wondershaper wlan0 240 240'"
#alias limfold='~/misc/fah.sh'
#alias bmine='cd ~ && tar -cvzf minecraft.`date +%d%m%y_%H%M%S`.tgz .minecraft/ && rsync -avcu mine*.tgz /media/data/files/ && rm -v mine*.tgz'
#alias transgui='~/misc/files/transmission_gui/transgui'
