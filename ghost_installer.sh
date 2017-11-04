#!/bin/bash

set_vars()
{
	# Main
	read -p "Enter website codename [html]: " WWW_CODENAME; WWW_CODENAME=${WWW_CODENAME:-html}
	read -p "Enter domain name [$WWW_CODENAME.com]: " DOMAIN_NAME; DOMAIN_NAME=${DOMAIN_NAME:-$WWW_CODENAME.com}
	read -p "Enter Ghost port [2367]: " GHOST_PORT; GHOST_PORT=${GHOST_PORT:-2367}
	read -p "Enter shell username: " SHELL_USERNAME
	echo "Set up Upstart script?"
	select choice in "Yes" "No"
	do
		case $choice in
			Yes ) UPSTART='true'; break;;
			No ) UPSTART='false'; break;;
		esac
	done
	
	LOG_NAME=$WWW_CODENAME
}

install_nginx()
{
	# Install Nginx
	apt-get update
	apt-get install -y curl
	apt-get install -y nginx
	
	# Configure server
	cp nginx_nodejs $WWW_CODENAME
	sed -i s/DOMAIN_NAME/$DOMAIN_NAME/g $WWW_CODENAME
	sed -i s/LOG_NAME/$LOG_NAME/g $WWW_CODENAME
	mv $WWW_CODENAME /etc/nginx/sites-available
	mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
	ln -s /etc/nginx/sites-available/$WWW_CODENAME /etc/nginx/sites-enabled/$WWW_CODENAME

	# Prepare firewall for SSL
	ufw enable
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
	
	# Prepare env
	mkdir -p /var/www/$WWW_CODENAME
	cd /var/www/$WWW_CODENAME
	if [ ! -z $SHELL_USERNAME ]; then
		chown -r $SHELL_USERNAME:$SHELL_USERNAME ./
		chmod g+w ./
		chmod g+s ./
	fi
	
	ghost install --port $GHOST_PORT
	
	if [ ! -z $UPSTART ]; then
		if [ $UPSTART = 'true' ]; then
			# Copy Upstart
			cp ghost_upstart.conf /etc/init/ghost.conf
			service ghost start
		fi
	fi
}

set_vars
apt-get update

./install_setup_mysql.sh $WWW_CODENAME
install_nginx
install_ghost

systemctl restart nginx
