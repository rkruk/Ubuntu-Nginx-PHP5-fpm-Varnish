#!/bin/bash

# Step 1: Ask for user input
echo "Welcome to the automated WordPress setup!"
echo "Please provide the following information."

# User inputs for site setup
read -p "Enter the username for the WordPress admin user: " username
read -sp "Enter the password for the WordPress admin user: " user_password
echo

# Secure root password
read -sp "Enter the MySQL root password: " secure_root_password
echo

# Site count and DB passwords
read -p "How many WordPress sites would you like to set up? (Enter a number): " num_sites
declare -A db_passwords
for i in $(seq 1 $num_sites); do
    read -sp "Enter password for the database of site $i: " db_passwords[$i]
    echo
done

# Site names
declare -A sites
for i in $(seq 1 $num_sites); do
    read -p "Enter the domain name for site $i (e.g., site$i.com): " sites[$i]
done

# Step 2: Initial Server Setup
sudo apt update && sudo apt upgrade -y
sudo apt install fail2ban ufw certbot python3-certbot-nginx iptables iptables-persistent nginx php-fpm php-mysql php-redis redis-server mariadb-server unzip curl wget imagemagick optipng jpegoptim logwatch wp-cli unattended-upgrades -y

# Configure UFW firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable

# Create the new user
sudo adduser $username
echo "$username:$user_password" | sudo chpasswd
sudo usermod -aG sudo $username

# Configure SSH and security settings
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Install Redis for object caching
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Enable automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Step 3: Check if WordPress is already installed for each site
for i in $(seq 1 $num_sites); do
    site_name=${sites[$i]}

    # Check if site exists
    if [ -d "/var/www/$site_name" ]; then
        read -p "WordPress is already installed for $site_name. Do you want to update, reinstall, or skip? (update/reinstall/skip): " action
        case $action in
            "update")
                echo "Updating WordPress for $site_name..."
                wp core update --path="/var/www/$site_name"
                wp plugin update --all --path="/var/www/$site_name"
                wp theme update --all --path="/var/www/$site_name"
                ;;
            "reinstall")
                echo "Reinstalling WordPress for $site_name..."
                sudo rm -rf /var/www/$site_name/*
                sudo curl -O https://wordpress.org/latest.tar.gz
                sudo tar xzvf latest.tar.gz
                sudo cp -r wordpress/* /var/www/$site_name
                sudo chown -R $username:$username /var/www/$site_name
                ;;
            "skip")
                echo "Skipping installation for $site_name."
                continue
                ;;
            *)
                echo "Invalid option. Skipping installation for $site_name."
                continue
                ;;
        esac
    else
        echo "Installing WordPress for $site_name..."
    fi

    # Step 4: Install SSL and Configure Nginx
    sudo certbot --nginx -d $site_name -d www.$site_name --non-interactive --agree-tos -m your-email@example.com
    sudo systemctl reload nginx

    # Force HTTP → HTTPS redirection
    sudo sed -i "/server_name $site_name www.$site_name;/a \    return 301 https://\$host\$request_uri;" /etc/nginx/sites-available/$site_name
    sudo systemctl reload nginx

    # Configure PHP OPcache, GZIP, Cache Headers
    echo "Enabling PHP OPcache"
    sudo apt install php-opcache -y
    echo "Enabling GZIP compression and HTTP/2 in Nginx"
    sudo sed -i '/http {/a \    gzip on;\n    gzip_types text/plain application/xml text/css application/javascript image/x-icon;' /etc/nginx/nginx.conf
    sudo sed -i '/http {/a \    server { listen 443 ssl http2; }' /etc/nginx/nginx.conf

    # Step 5: Install WordPress core for each site
    sudo mkdir -p /var/www/$site_name
    sudo curl -O https://wordpress.org/latest.tar.gz
    sudo tar xzvf latest.tar.gz
    sudo cp -r wordpress/* /var/www/$site_name
    sudo chown -R $username:$username /var/www/$site_name

    # Set up database for WordPress
    sudo mysql -u root -p$secure_root_password -e "CREATE DATABASE wp_$site_name;"
    sudo mysql -u root -p$secure_root_password -e "CREATE USER 'wp_$site_name'@'localhost' IDENTIFIED BY '${db_passwords[$i]}';"
    sudo mysql -u root -p$secure_root_password -e "GRANT ALL PRIVILEGES ON wp_$site_name.* TO 'wp_$site_name'@'localhost';"
    sudo mysql -u root -p$secure_root_password -e "FLUSH PRIVILEGES;"

    # Install WordPress using WP-CLI
    wp core install --url="http://$site_name" --title="$site_name" --admin_user="$username" --admin_password="$user_password" --admin_email="admin@$site_name" --path="/var/www/$site_name"

    # Install WP Super Cache plugin
    wp plugin install wp-super-cache --activate --path="/var/www/$site_name"
done

# Set up cron jobs for auto SSL renewal and WP updates
echo "0 0 * * * certbot renew --quiet" | sudo tee -a /etc/crontab
echo "0 3 * * * wp core update --path=/var/www/$site_name" | sudo tee -a /etc/crontab

# Install Logwatch
echo "Installing Logwatch..."
apt-get install -y logwatch

# Configure Logwatch
echo "Configuring Logwatch..."
echo "MailTo = root" > /etc/logwatch/conf/logwatch.conf
echo "Detail = High" >> /etc/logwatch/conf/logwatch.conf
echo "Range = yesterday" >> /etc/logwatch/conf/logwatch.conf
echo "Service = http" >> /etc/logwatch/conf/logwatch.conf
echo "Format = text" >> /etc/logwatch/conf/logwatch.conf

# Test Logwatch configuration
logwatch --detail high --service http --range today --format text

# Backup Existing WordPress Installation
echo "Backing up existing WordPress installations..."
for i in $(seq 1 $num_sites); do
    site_name=${sites[$i]}
    tar -czf "/var/www/$site_name-backup-$(date +%F).tar.gz" /var/www/$site_name
done

echo "WordPress setup is complete with SSL, security, performance optimizations, and backups!"
