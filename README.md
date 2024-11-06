<p align="center">
  <img width="260" height="161" src="https://github.com/rkruk/Ubuntu-Nginx-PHP5-fpm-Varnish/blob/master/images/linux-ubuntu-nginx-mysql-php-wordpress.jpg">
</p>

<H4 style="text-align: center"> A step-by-step guide for setting up a multi-site WordPress environment on an Ubuntu/Debian VPS, optimized for speed and security.<br><br>
This guide covers everything from server setup to automated maintenance and monitoring.</h4><br><br>

Step 1: Initial Server Setup:<br>
1.1 Update and Secure the System:<br><br>
Log in to your VPS as the root user or an initial SSH user and update all packages.

```bash
sudo apt update && sudo apt upgrade -y
```
<br>
1.2 Create a New User:<br>
For security, create a non-root user to manage the WordPress instances.

```bash
adduser wordpressadmin
usermod -aG sudo wordpressadmin
```
<br>
1.3 Configure SSH Access for the New User:<br>
Copy SSH keys to the new user:

```bash
rsync --archive --chown=wordpressadmin:wordpressadmin ~/.ssh /home/wordpressadmin
``` 
<br>
Now, switch to the new user:

```bash
su - wordpressadmin
```
<br>
Disable root login over SSH for added security. Open <b>/etc/ssh/sshd_config</b> and set:

```bash
PermitRootLogin no
```
<br>
Restart SSH:

```bash
sudo systemctl restart ssh
```
<br>
Step 2: Firewall Configuration:
Configure <b>ufw</b> (Uncomplicated Firewall) to allow SSH, HTTP, and HTTPS traffic.

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```
<br>
Step 3: Install Essential Packages:<br>
Install necessary packages for managing and optimizing WordPress, including Nginx, PHP, MySQL, and Redis.

```bash
sudo apt install nginx php-fpm php-mysql php-redis redis-server mariadb-server unzip curl -y
```
<br>
Step 4: MySQL Database Setup:<br>
4.1 Secure MySQL Installation:<br>
Run the MySQL secure installation script to improve security.

```bash
sudo mysql_secure_installation
```
<br>
4.2 Create a Database and User for Each WordPress Site:<br>
For each WordPress instance, create a dedicated database and user:<br>

```bash
sudo mysql -u root -p

CREATE DATABASE wp_database1;
CREATE USER 'wp_user1'@'localhost' IDENTIFIED BY 'securepassword1';
GRANT ALL PRIVILEGES ON wp_database1.* TO 'wp_user1'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```
<br>
Repeat for additional databases, using unique database names and passwords.<br><br>

4.3 Optimize MySQL Configuration:<br>
Edit <b>/etc/mysql/mysql.conf.d/mysqld.cnf</b> for optimal performance:

```bash
[mysqld]
innodb_buffer_pool_size = 2G          # Adjust per server RAM
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1
max_connections = 100
max_allowed_packet = 64M
```
<br>
Restart MySQL:<br>

```bash
sudo systemctl restart mysql
```
<br>
Step 5: Configure PHP for WordPress:<br>
5.1 Tune PHP Settings:<br>
Edit <b>/etc/php/8.2/fpm/php.ini</b> for optimized performance. Adjust these values according to the expected site load and server memory:

```bash
memory_limit = 512M
upload_max_filesize = 50M
post_max_size = 50M
max_execution_time = 300
max_input_vars = 5000
```
<br>
5.2 Enable PHP Extensions for WordPress:

```bash
sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-zip -y
```
<br>
5.3 Configure PHP-FPM Pools:<br>
Each WordPress site should run in its own PHP-FPM pool to improve isolation. Create pool configuration files in <b>/etc/php/8.2/fpm/pool.d/</b>, using unique names and users.<br><br>

Example (/etc/php/8.2/fpm/pool.d/wp_site1.conf):

```bash
[wp_site1]
user = wordpressadmin
group = wordpressadmin
listen = /run/php/php8.2-fpm-wp_site1.sock
pm = dynamic
pm.max_children = 10
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6
```
<br>
Reload PHP-FPM:

```bash
sudo systemctl reload php8.2-fpm
```

Step 6: Install and Configure Nginx:<br>
6.1 Set Up Nginx Server Blocks:<br>
Create a new server block configuration for each site in <b>/etc/nginx/sites-available/</b>.<br><br>

Example (<b>/etc/nginx/sites-available/site1.com</b>):

```nginx

server {
    listen 80;
    server_name site1.com www.site1.com;
    root /var/www/site1.com;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm-wp_site1.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
```
<br>
Enable the configuration:

```bash
sudo ln -s /etc/nginx/sites-available/site1.com /etc/nginx/sites-enabled/
```
<br>
Repeat for each site. Test and reload Nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```
<br>
Step 7: Set Up Redis for Object Caching:<br>
7.1 Install Redis and Configure for WordPress:<br>
Edit <b>/etc/redis/redis.conf</b> to limit memory usage and enable <b>LRU cache</b> eviction:

```bash
maxmemory 256mb
maxmemory-policy allkeys-lru
```
<br>
Restart Redis:

```bash
sudo systemctl restart redis-server
```
<br>
7.2 Configure WordPress to Use Redis:<br>
Install the Redis Object Cache plugin for each WordPress site, then add the following to each site’s <b>wp-config.php</b>:

```php
define('WP_CACHE', true);
define('WP_REDIS_HOST', '127.0.0.1');
define('WP_REDIS_PORT', 6379);
```
<br><br>
Activate Redis caching in the WordPress admin panel for each site.<br>

Step 8: WordPress Setup and Permissions:<br>
8.1 Install WordPress:<br>
Download and set up WordPress for each site:

```bash
curl -O https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
sudo mv wordpress /var/www/site1.com
```
<br>
8.2 Set Secure Permissions:

```bash
sudo chown -R wordpressadmin:www-data /var/www/site1.com
sudo find /var/www/site1.com -type d -exec chmod 755 {} \;
sudo find /var/www/site1.com -type f -exec chmod 644 {} \;
```

8.3 Configure <b>wp-config.php</b>:<br>
Edit <b>wp-config.php</b> for each site, adding security salts from the WordPress Secret Key Generator, and setting up database credentials.<br>

Step 9: Enable Automatic Updates for WordPress, Themes, and Plugins:<br>
Add these lines to each site’s <b>wp-config.php</b>:

```php
define('WP_AUTO_UPDATE_CORE', true);
add_filter('auto_update_plugin', '__return_true');
add_filter('auto_update_theme', '__return_true');
```
<br>
Step 10: Automated Maintenance and Monitoring:<br>
10.1 Database Optimization Cron Job:<br>
Add a cron job for MySQL database optimization:<br>

```bash
crontab -e
```
<br>
Add the following line:

```bash
@weekly mysqlcheck -o --all-databases -u root -p'your_mysql_password'
```
<br>
10.2 Nginx and PHP Monitoring with systemd:<br>
Set up monitoring for Nginx and PHP-FPM to ensure they restart on failure:

```bash
sudo systemctl enable --now nginx
sudo systemctl enable --now php8.2-fpm
```
<br>
10.3 Set Up Basic Uptime Monitoring (Optional):<br>
Use a service like UptimeRobot to notify you if your sites go down, as budget constraints restrict in-depth monitoring.<br><br><br>

Your VPS is now set up to host multiple optimized and secure WordPress instances, complete with caching, database tuning, automated updates, and basic monitoring.<br><br>
<b>The End</b><br><br>
        
