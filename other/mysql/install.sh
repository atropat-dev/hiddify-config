#!/bin/bash

if ! command -v mysql; then
    sudo apt install -y mariadb-server
fi
if [ ! -f "mysql_pass" ]; then
    echo "Generating a random password..."
    random_password=$(openssl rand -base64 40)
    echo "$random_password" >"mysql_pass"
    chmod 600 "mysql_pass"
    # Secure MariaDB installation
    sudo mysql_secure_installation <<EOF
y
$random_password
$random_password
y
y
y
y
EOF

    # Disable external access
    sudo sed -i 's/bind-address/#bind-address/' /etc/mysql/mariadb.conf.d/50-server.cnf
    sudo systemctl restart mariadb

    # Create user with localhost access
    sudo mysql -u root -f <<MYSQL_SCRIPT
CREATE USER 'hiddifypanel'@'localhost' IDENTIFIED BY '$random_password';
ALTER USER 'hiddifypanel'@'localhost' IDENTIFIED BY '$random_password';

GRANT ALL PRIVILEGES ON *.* TO 'hiddifypanel'@'localhost';
CREATE DATABASE hiddifypanel;
GRANT ALL PRIVILEGES ON hiddifypanel.* TO 'hiddifypanel'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

    echo "MariaDB setup complete."

fi
