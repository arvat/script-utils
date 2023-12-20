#!/bin/sh
# Docker for wsl installation script
# run as root

#install docker
apt update
apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt-cache policy docker-ce
echo "#"
echo "#select iptables-legacy"
echo "#"
update-alternatives --config iptables
apt -y install docker-ce

#install docker-compose
curl -L https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

#add permisions to run docker in current user
usermod -aG docker $USER

#add shared socket
mdir /mnt/wsl/shared-docker
chmod 755 /mnt/wsl/shared-docker
echo '{ "hosts": ["unix:///mnt/wsl/shared-docker/docker.sock"] }' > /etc/docker/daemon.json

#start docker
service docker start