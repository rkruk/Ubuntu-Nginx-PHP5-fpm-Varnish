# Redirect to non-www
server {
    listen 8080;
    server_name www.example.com;
    return 301 $scheme://example.com$request_uri;
}

server {
 
    listen 8080;

    # Document root
    root /var/www/example.com;

    # Try static files first, then php
    index index.html index.htm index.php;

    # Specific logs for this vhost
    access_log /var/log/nginx/example.com-access.log;
    error_log  /var/log/nginx/example.com-error.log error;

    # Make site accessible from http://localhost/
    server_name example.com;

    # Specify a character set
    charset utf-8;

    # Redirect needed to "hide" index.php
    location / {
            try_files $uri $uri/ /index.php?q=$uri&$args;
    }

    # Don't log robots.txt or favicon.ico files
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt { access_log off; log_not_found off; }
    location = /apple-touch-icon.png { access_log off; log_not_found off; }
    location = /apple-touch-icon-precomposed.png { access_log off; log_not_found off; }

    # 404 errors handled by our application
    error_page 404 /index.html;

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
              root /usr/share/nginx/www;
    }

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    location ~ \.php$ {

            fastcgi_buffers 8 256k;
            fastcgi_buffer_size 128k;
            fastcgi_intercept_errors on;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            try_files $uri =404;
            fastcgi_pass unix:/var/run/php5-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
    }

    # Deny access to .htaccess
    location ~ /\. { deny  all; access_log off; log_not_found off; }
    location ~ /\.ht {
            deny all;
    }        

    # rewrite for Yoast sitemap
    location ~ ([^/]*)sitemap(.*)\.x(m|s)l$ {
        rewrite ^/sitemap\.xml$ /sitemap_index.xml permanent;
        rewrite ^/([a-z]+)?-?sitemap\.xsl$ /index.php?xsl=$1 last;
	    rewrite ^/sitemap_index\.xml$ /index.php?sitemap=1 last;
	    rewrite ^/([^/]+?)-sitemap([0-9]+)?\.xml$ /index.php?sitemap=$1&sitemap_n=$2 last;

    ## following lines are options. Needed for wordpress-seo addons
        rewrite ^/news_sitemap\.xml$ /index.php?sitemap=wpseo_news last;
	    rewrite ^/locations\.kml$ /index.php?sitemap=wpseo_local_kml last;
	    rewrite ^/geo_sitemap\.xml$ /index.php?sitemap=wpseo_local last;
	    rewrite ^/video-sitemap\.xsl$ /index.php?xsl=video last;

	    access_log off;
    }

# Define default caching of 24h
    expires 86400s;
    add_header Pragma public;
    add_header Cache-Control "max-age=86400, public, must-revalidate, proxy-revalidate";

# Do not allow access to files giving away your WordPress version
    location ~ /(\.|wp-config.php|readme.html|licence.txt) {
        return 404;
    }

# Rewrite for versioned CSS+JS via filemtime
    location ~* ^.+\.(css|js)$ {
        rewrite ^(.+)\.(\d+)\.(css|js)$ $1.$3 last;
        expires 31536000s;
        access_log off;
        log_not_found off;
        add_header Pragma public;
        add_header Cache-Control "max-age=31536000, public";
}
# Expire rules for static content

# cache.appcache, your document html and data
location ~* \.(?:manifest|appcache|html?|xml|json)$ {
  expires -1;
  access_log /var/log/nginx/static.log;
}

# Feed
location ~* \.(?:rss|atom)$ {
  expires 1h;
  add_header Cache-Control "public";
}

# Media: images, icons, video, audio, HTC
location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc)$ {
  expires 1M;
  access_log off;
  add_header Cache-Control "public";
}

# CSS and Javascript
location ~* \.(?:css|js)$ {
  expires 1y;
  access_log off;
  add_header Cache-Control "public";
}

    # Cross domain webfont access
    location ~* \.(?:ttf|ttc|otf|eot|woff)$ {
    add_header "Access-Control-Allow-Origin" "*";

    expires 1M;
    access_log off;
    add_header Cache-Control "public";
    }

    # Prevent clients from accessing hidden files (starting with a dot)
    # This is particularly important if you store .htpasswd files in the site hierarchy
    location ~* (?:^|/)\. {
    deny all;
    }

    # Prevent clients from accessing to backup/config/source files
    location ~* (?:\.(?:bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)|~)$ {
    deny all;
    }
}
