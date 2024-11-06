<p align="center">
  <img width="260" height="161" src="https://github.com/rkruk/Ubuntu-Nginx-PHP5-fpm-Varnish/blob/master/images/linux-ubuntu-nginx-mysql-php-wordpress.jpg">
</p>
<h2>Automated WordPress installation on Ubuntu/Debian VPS - Setup Script and Howto:</h2>
<h4></h4>This script automates the installation of a secure and optimized WordPress environment on a server.</h4><br><br> It handles:

- Server setup (including SSH, security, and firewall configurations)<br>
- WordPress installation and configuration<br>
- SSL certificate installation and redirection to HTTPS<br>
- Performance optimizations (e.g., Redis, PHP OPcache)<br>
- Security hardening (e.g., fail2ban, ModSecurity, PHP hardening)<br>
- Database optimization<br>
- Automatic updates and backups<br>
- Log monitoring with Logwatch
<h4>Features:</h4>
Security Hardening:<br>
  - SSH access hardening<br>
  - Fail2ban installation and configuration<br>
  - Automatic SSL certificate installation and renewal using Let's Encrypt<br>
  - Secure PHP settings and Nginx configurations<br>
  - Firewall configuration using UFW<br>
  - Automatic security updates for system and WordPress<br>
<br>
Performance Optimization:<br>
  - Redis installation and configuration for object caching<br>
  - PHP OPcache for improved PHP performance<br>
  - GZIP compression and HTTP/2 enabled in Nginx<br>
  - Caching headers for static files<br>
  - Image optimization (e.g., OptiPNG, JPEGoptim)<br>
<br>
Site Configuration:<br>
  - Nginx server blocks (virtual hosts) for each WordPress site<br>
  - Automatic database and WordPress installation for multiple sites<br>
  - Regular updates for WordPress core and plugins via cron jobs<br>
<br>
Backup Automation:<br>
  - Automated backups of WordPress databases and files using `wp-cli` and cron jobs<br>
<br>
Log Monitoring:<br>
  - Install Logwatch for log monitoring and daily summaries<br>
<br>
<h4>Prerequisites</h4>
- A fresh Ubuntu/Debian server
- A domain name pointed to the server for SSL (Let's Encrypt)<br>
- SSH access with root privileges<br>
- Nginx, MariaDB, PHP, and Redis installed<br>
<br>
<h4>Installation</h4>
<h4> 1. Clone or Download the Script</h4>
<br>
You can either clone the GitHub repository or download the script.<br><br>

```bash
git clone https://github.com/rkruk/Ubuntu-Nginx-PHP-Redis.git
```

```bash
cd Ubuntu-Nginx-PHP-Redis
```

2. Update the Script (Optional)<br>
If necessary, update the script to fit your server environment. You may want to adjust paths, usernames, or configurations for specific sites.<br>
<br>
3. Make the Script Executable<br>
Ensure that the script is executable by running:<br>

```bash
chmod +x wordpress-setup.sh
```

4. Run the Script<br>
Execute the script with root privileges to begin the installation:<br>

```bash
sudo ./wordpress-setup.sh
```

5. Follow the Prompts<br>
The script will ask you for the following information during the setup:<br>
<br>
- WordPress Admin Username: The admin username for the WordPress sites.<br>
- WordPress Admin Password: The admin password for WordPress.<br>
- MySQL Root Password: The password for the MySQL root user.<br>
- Number of Sites: How many WordPress sites you want to install.<br>
- Database Password for Each Site: Each site’s database password.<br>
- Site Domain Names: The domain names for each WordPress site (e.g., example.com).<br><br>
6. Verify the Installation<br>
Once the script completes, the following will be set up:<br>
<br>
- Nginx virtual hosts for each WordPress site<br>
- SSL certificates for each site with automatic HTTPS redirection<br>
- Redis configured for object caching<br>
- PHP OPcache enabled for better PHP performance<br>
- Fail2ban set up to protect against brute-force attacks<br>
- Firewall (UFW) configured to allow OpenSSH and Nginx traffic<br>
- PHP security and hardening applied<br>
- Automated backups and updates for WordPress<br>
- Logwatch installed for log monitoring<br><br>
7. Check the Logs and SSL Certificates<br>
You can check the status of your SSL certificates and log monitoring:<br>
<br>

```bash
# Check SSL Certificate Renewal
sudo certbot renew --dry-run

# Check Logwatch Reports
sudo logwatch --detail high --service http --range today --format text
```

Additional Configuration (Optional)<br>
A. Install WordPress Security Plugins (e.g., Wordfence or Sucuri)<br>
WordPress plugins like Wordfence or Sucuri can provide additional layers of protection. You can install them manually via the WordPress admin panel or use wp-cli:

```bash
wp plugin install wordfence --activate
```

B. Configure Database and WordPress Backup Automation<br>
The script sets up basic database and file backup automation using cron jobs. If you want more frequent backups or custom schedules, you can modify the cron job schedules in /etc/crontab.<br>

```bash
# Example cron job for daily backups (customize as needed)
0 0 * * * wp db export --path=/var/www/html --add-drop-table /backups/$(date +\%F).sql
```

C. Optimize the Database<br>
You can set up a cron job to automatically optimize your WordPress database periodically:

```bash
# Example cron job for database optimization
0 2 * * * wp db optimize --path=/var/www/html
```

D. Performance Enhancements with Varnish (Optional)<br>
For high-traffic sites, consider installing and configuring Varnish as a reverse proxy to further speed up your WordPress sites.<br>
<br><br>
Troubleshooting<br>
- SSL Not Working: Ensure your domain is correctly pointed to the server and you’ve configured Nginx to handle SSL.<br>
- WordPress Not Accessible: Check Nginx logs (/var/log/nginx/access.log) and WordPress error logs (wp-content/debug.log) for issues.<br>
- Redis Not Connecting: Make sure Redis is running (sudo systemctl status redis-server) and that WordPress is properly configured for Redis caching.<br><br>
Security Considerations<br>
- Regularly check logs and monitor your server’s health.<br>
- Use strong, unique passwords for WordPress admin and database accounts.<br>
- Set up automatic security updates for your OS and WordPress.<br>
- Ensure your SSL certificates are automatically renewed.<br>
- Review your firewall settings periodically to block unnecessary traffic.<br><br><br>
License<br>
This script is open-sourced and can be freely modified for personal or commercial use.<br>
Please contribute improvements and report issues via the repository's issue tracker.<br>
Thank you for any tips, improvements, recommendations or questions.<br><br>

