# network_setup.sh

# check env var
if test -z "$SSH_PORT"
then
    echo "SSH_PORT is not set"
    exit 1
fi
echo "SSH_PORT: $SSH_PORT"

if test -z "$LAN_IP"
then
    echo "LAN_IP is not set"
    exit 1
fi
echo "LAN_IP: $LAN_IP"


##### install packages #####
apt update && apt upgrade -y
apt install -y vim htop curl tmux git zip unzip
apt install ufw -y && ufw disable
apt autoremove && apt clean
##### install packages #####


##### setup SSH #####
# Restore default settings

# Edit sshd config
# make sure /etc/ssh/sshd_config should have
# "Include /etc/ssh/sshd_config.d/*.conf" at the top
# this is crucial for sylab-sshd.conf to take effect
conf_file="/etc/ssh/sshd_config.d/sylab-sshd.conf"

echo "Port $SSH_PORT" > $conf_file
echo "Protocol 2" >> $conf_file
# Authentication:
echo "LoginGraceTime 30" >> $conf_file
echo "PermitRootLogin no" >> $conf_file
echo "MaxAuthTries 3" >> $conf_file
echo "MaxSessions 30" >> $conf_file

# Restart sshd
systemctl restart ssh
##### setup SSH #####


##### setup firewall #####
NTU_IP=140.112.0.0/16

# Reset ufw to default
ufw reset

# Settings
# (a) whitelist
ufw allow from $LAN_IP comment 'LAN'
ufw limit from $NTU_IP to any port $SSH_PORT proto tcp comment 'modified SSH port'
# (b) If we don’t have a valid reason to keep UFW’s logging active, 
# we can disable it because it can take up dozens of gigabytes, 
# filling up our server’s storage:
ufw logging off

# Enable firewall
ufw enable
##### setup firewall #####