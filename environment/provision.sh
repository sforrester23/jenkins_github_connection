#!/bin/bash

# updates the list of packages: what new things can I install?
sudo apt-get update -y

# updates the actual packages: of the existing things: what can I update?
sudo apt-get upgrade -y

# install nginx
sudo apt-get install nginx -y
sudo systemctl start nginx -y

# update and install java8
sudo apt update
sudo apt install openjdk-8-jdk -y

# install nodejs
sudo apt-get install curl -y
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install nodejs -y

# get the necessaries for jenins to install
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# install jenkins
sudo apt update
sudo apt install jenkins -y

# get the jenkins status
systemctl status jenkins

# allow the port
sudo ufw enable -y
sudo ufw allow OpenSSH
sudo ufw allow 8080

# get the password
# sudo cat /var/lib/jenkins/secrets/initialAdminPassword
# get the status
# sudo ufw status

# Install ngrok
sudo npm i -g ngrok --unsafe-perm=true --allow-root
