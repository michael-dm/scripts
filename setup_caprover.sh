#!/bin/bash
# Setup CapRover on Ubuntu 18.04

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Updating system..."
apt update && apt upgrade -y

# Change the SSH port to 202
echo "Changing SSH port to 202..."
sed -i 's/^#\?Port .*/Port 202/' /etc/ssh/sshd_config

# Disable password login
echo "Disabling password login..."
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart the SSH service
echo "Restarting SSH service..."
systemctl restart sshd
apt install fail2ban -y

# Install Docker
echo "Installing Docker..."
apt install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

VERSION_STRING=5:19.03.15~3-0~ubuntu-bionic
apt install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-compose-plugin -y

# Install CapRover
echo "Installing CapRover..."
docker run -p 80:80 -p 443:443 -p 3000:3000 -v /var/run/docker.sock:/var/run/docker.sock -v /captain:/captain caprover/caprover

# setup firewall
echo "Setting up firewall..."
ufw allow 202,80,443,3000,996,7946,4789,2377/tcp
ufw allow 7946,4789,2377/udp
# force enable
ufw --force enable

echo "Done!"
