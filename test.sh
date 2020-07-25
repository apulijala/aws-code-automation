#!/bin/bash -ex
# New way of mount EFS Drive according to AWS specification

result=$(sudo cat /etc/os-release  | head -1 | awk -F = '{print $2}' | sed -E 's/"//g' )
if [[ "$result" =~ [Cc]entos  ]]
then
    sudo yum -y install git
    git clone https://github.com/aws/efs-utils
    sudo yum -y install make
    sudo yum -y install rpm-build
    cd efs-utils
    sudo make rpm
    sudo yum -y install ./build/amazon-efs-utils*rpm
    sudo yum install -y nmap

fi

if [[ "$result" =~ [Uu]buntu   ]]
then
    sudo apt-get -y install binutils
    git clone https://github.com/aws/efs-utils
    sudo apt-get -y install binutils
    cd efs-utils/
    ./build-deb.sh
    sudo sh -c 'apt-get update && apt-get install stunnel4'
    sudo apt-get -y install ./build/amazon-efs-utils*deb
fi

while ! nc -z fs-0b6027fa.efs.eu-west-2.amazonaws.com 2049; do
    sleep 10
done

sudo mkdir -p /var/www/html
sudo sed -i -E 's/stunnel_check_cert_hostname =.*/stunnel_check_cert_hostname = false/' /etc/amazon/efs/efs-utils.conf
sudo bash -c "echo fs-0b6027fa  /var/www/html efs  _netdev,tls,accesspoint=fsap-03d2c55dd7232eb51 0 0 >> /etc/fstab"
sudo mount -a
sudo df -h


