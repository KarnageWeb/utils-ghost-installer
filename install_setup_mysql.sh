[ $# > 0 ] && WWW_CODENAME=$1
WWW_CODENAME=${WWW_CODENAME:-www}

# Install
# INTERRUPT : Set root password
apt-get install -y mysql-server

# INTERRUPT: External installer 
mysql_secure_installation

# Read vars
echo "Set up user and DB?"
select choice in "Yes" "No"
do
	case $choice in
		Yes ) $UPSTART=true; break;;
		No ) $UPSTART=false; break;;
	esac
done

if [ $SETUP_USER = 'true' ]; then

	read -p "Enter MySQL root password [root]: " DB_ROOT_PWD; DB_ROOT_PWD=${DB_ROOT_PWD:-root}
	read -p "Enter MySQL WP username [$WWW_CODENAME]: " DB_USER; DB_USER=${DB_USER:-$WWW_CODENAME}
	read -p "Enter MySQL WP password [$WWW_CODENAME]: " DB_PWD; DB_PWD=${DB_PWD:-$WWW_CODENAME}
	read -p "Enter MySQL DB name [$WWW_CODENAME]: " DB_NAME; DB_NAME=${DB_NAME:-$WWW_CODENAME}

	# Run queries
	mysqlexec='mysql -uroot -p'${DB_ROOT_PWD}' -e'

	$mysqlexec "DROP USER ${DB_USER}@localhost;"
	$mysqlexec "CREATE USER ${DB_USER}@localhost IDENTIFIED BY '${DB_PWD}';"
	$mysqlexec "CREATE DATABASE ${DB_NAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
	$mysqlexec "GRANT ALL ON ${DB_NAME}.* TO ${DB_USER}@localhost;"
	$mysqlexec "FLUSH PRIVILEGES;"
fi
