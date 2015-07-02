<p align="center">![alt tag](https://github.com/rkruk/Ubuntu-Nginx-PHP5-fpm-Varnish/blob/master/images/linux-ubuntu-nginx-mysql-php-wordpress.jpg)
## <p align="center"><b> HOW TO INSTALL FAST UBUNTU WEBSERVER </b>
## <p align="center">with 
## <p align="center">VARNISH, PHP5-fpm, NGINX
## <p align="center"> +
## <p align="center">Multidomain Setup
## <p align="center"> for
## <p align="center">HTML Websites & Wordpress)
<br>
<br>
<p align="center"><b>***</b>
#### <p align="center"><b> Step by step: </b> <br> 

 Console commands, configuration files and real life examples for setting up Web Server based on <b>Ubuntu</b> + <b>NGINX</b> + <b>Varnish</b> + <b>WORDPRESS</b> + <b>HTML Websites</b>. <br> 
 
<i>Additionally, I've added my 'reasonable speed' and efficiency optimizations for small (to medium) size servers (256mb to 2gb processor + 256mb to 3gb RAM).</i> <br> 

<i>This instructions are 100% compatible with Ubuntu (tested on 13.04, 13.10, 14.04, 14.10 and 15.04), Debian (testing line)- but most of the work flow after carefully reading can be adapted to any Linux web server installation scenario.</i> <br>
<br>


This is a cheat sheet I use every single time for my own server installs, when I'm setting up a production web server. As it is rather not exciting and time consuming task - I have decided to make a small cheatsheet log with all those commands, configs - necessary to set things up and running.. without digging through various manuals, wikis, forums. <br> 

Usually I use cloud based virtual servers but it <i>should</i> works just for any working web server based on Ubuntu. <br> 
<br> 
<b> <i> Please use your own brain! And don't blindly copy and paste commands to your terminal - for your own safety. </i></b> <br> 
<br> 
<p align="center"><b>Follow instructions 
<p align="center"><b>from 'ubuntu command line' file. <br> 

'Ubuntu command line' file contains all console commands, instructions, and file examples needed for complete installation.
<br />
<br />
<center><b> How you should read files hierarchy: </b></center>
<br />
```
 /   (root)

 |

   --> /etc

 |        |

 |         /etc/nginx

 |                     |

 |                      /etc/nginx/html (for 50.. sites)

 |                      /etc/nginx/sites-available (template configs for websites)

 |                      /etc/nginx/sites-enabled (enabled template configs)

 |

 --> /var

        |

        /var/www (here are the dragons)
        
