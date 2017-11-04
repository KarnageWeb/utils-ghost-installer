#!/bin/bash

set_vars()
{
	# Main
	read -p "Root. THIS DIRECTORY WILL BE ERASED! /var/www/[html]: " WWW_CODENAME; WWW_CODENAME=${WWW_CODENAME:-html}
	read -p "Enter domain name (no port) [$WWW_CODENAME.com]: " DOMAIN_NAME; DOMAIN_NAME=${DOMAIN_NAME:-$WWW_CODENAME.com}
	read -p "Enter nginx listen port [80]: " LISTEN_PORT; LISTEN_PORT=${LISTEN_PORT:-80}
	read -p "Enter Ghost server port [2367]: " SERVER_PORT; SERVER_PORT=${SERVER_PORT:-2367}
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

setup_ghost()
{
	# Configure server
	cp nginx_nodejs $WWW_CODENAME
	sed -i s/DOMAIN_NAME/$DOMAIN_NAME/g $WWW_CODENAME
	sed -i s/LOG_NAME/$LOG_NAME/g $WWW_CODENAME
	sed -i s/LISTEN_PORT/$LISTEN_PORT/g $WWW_CODENAME
	sed -i s/SERVER_PORT/$SERVER_PORT/g $WWW_CODENAME
	mv $WWW_CODENAME /etc/nginx/sites-available
	mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
	ln -s /etc/nginx/sites-available/$WWW_CODENAME /etc/nginx/sites-enabled/$WWW_CODENAME
	ufw allow $LISTEN_PORT
	systemctl restart nginx
	
	# Prepare env
	mkdir -p /var/www/$WWW_CODENAME
	cd /var/www/$WWW_CODENAME
	if [ ! -z $SHELL_USERNAME ]; then
		chown -R $SHELL_USERNAME:$SHELL_USERNAME ./
		chmod -R g+ws ./
	fi
	
	rm -rf .[^.] .??*
	ghost install --port $SERVER_PORT
	
	if [ ! -z $UPSTART ]; then
		if [ $UPSTART = 'true' ]; then
			# Copy Upstart
			cp ghost_upstart.conf /etc/init/ghost.conf
			service ghost start
		fi
	fi
}

chmod +x *.sh
set_vars
setup_ghost