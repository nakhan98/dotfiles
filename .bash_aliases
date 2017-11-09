# General
alias new='aptitude search ~U'
alias upgrade="sudo aptitude update && sudo aptitude safe-upgrade"
alias apv='aptitude versions'
alias proses='ps auxf | less'
alias ll="ls -haltr"
alias tma="tmux attach -d"
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
