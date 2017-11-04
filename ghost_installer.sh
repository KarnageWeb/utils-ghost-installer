#!/bin/bash

install_nginx()
{
	# Install Nginx
	apt-get update
	apt-get install -y curl
	apt-get install -y nginx
	
	# Prepare firewall for SSL
	ufw allow 'Nginx Full'
	service ufw restart
}

install_ghost()
{
	# Ensure MySQL is installed
	MYSQL_INSTALLED=$(which mysql)
	[ MYSQL_INSTALLED = "" ] && apt-get install mysql-server
	
	# Install NodeJS
	curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash 
	apt-get install -y nodejs
	
	# Install Ghost CLI
	npm i -g ghost-cli
}

chmod +x *.sh
apt-get update

./install_setup_mysql.sh $WWW_CODENAME
install_nginx
install_ghost