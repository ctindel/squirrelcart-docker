#!/bin/bash -e

yum -y install vim git unzip screen

echo ". /home/centos/utils/utils.sh" >> /root/.bash_profile
echo ". /home/centos/utils/utils.sh" >> /home/centos/.bash_profile
