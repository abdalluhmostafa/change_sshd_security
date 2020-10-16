#!/bin/bash -e
##-------------------------------------------------------------------
## @copyright Abdalluh Mostafa
## 
## https://raw.githubusercontent.com/DennyZhang/devops_public/tag_v1/LICENSE
##
## File : sshd_security.sh
## Author : Denny <abdalluh.mostafa@gmail.com>
## --
## Created : <2020-10-16>
##
## This script will deny Password Authentication, Permit Root Login and change ssh port.
##  
## Please make sure you have other users (not root) can access server with ssh key before run script 
## 
##-------------------------------------------------------------------
read -p 'Enter SSH PORT: ' ssh_port

function log() {
    local msg=$*
    date_timestamp=$(date +['%Y-%m-%d %H:%M:%S'])
    echo -ne "$date_timestamp $msg\n"

    if [ -n "$LOG_FILE" ]; then
        echo -ne "$date_timestamp $msg\n" >> "$LOG_FILE"
    fi
}

function reconfigure_sshd_port() {
    local ssh_port=${1?}
    log "Change sshd port to $ssh_port"
    sed -i "s/Port .*$/Port $ssh_port/g" /etc/ssh/sshd_config
    log "Restart sshd to take effect"
    nohup systemctl restart sshd &
}

function disable_passwd_login() {
    log "Disable ssh passwd login: PasswordAuthentication no"
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/g' \
        /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' \
        /etc/ssh/sshd_config
}
function disable_root_login() {
    log "Disable ssh root login: PermitRootLogin no"
    sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/g' \
        /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' \
        /etc/ssh/sshd_config
}


LOG_FILE="/var/log/update_sshd_security.log"

################################################################################
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root." 1>&2
    exit 1
fi
reconfigure_sshd_port "$ssh_port"
disable_passwd_login
disable_root_login

## File : update_sshd_security.sh ends
