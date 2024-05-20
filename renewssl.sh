#!/bin/bash

# Replace 'proxy' with the actual container name if needed
container_name="proxy"
domain="asbc.ghs-hpd-timtooni.org"
email="clement.quoda@gmail.com"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Stop Apache
lxc exec $container_name -- systemctl stop apache2 || handle_error "Failed to stop Apache"

# Delete existing certificate
echo -e "1\n" | lxc exec $container_name -- certbot delete || handle_error "Failed to delete existing certificate"

# Renew certificate
lxc exec $container_name -- certbot certonly -d $domain -m $email --agree-tos --standalone || handle_error "Failed to renew certificate"

# Restart Apache
lxc exec $container_name -- systemctl restart apache2 || handle_error "Failed to restart Apache"

echo "SSL certificate renewal completed for $domain"
