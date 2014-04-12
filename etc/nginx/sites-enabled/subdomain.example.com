# Redirect to non-www
server {
    listen 8080;
    server_name www.subdomain.example.com;
    return 301 $scheme://subdomain.example.com$request_uri;
}

server {
 
    listen 8080;

    # Document root
    root /var/www/example/subdomain/;

    # Try static files first, then php
    index index.html index.htm;

    # Specific logs for this vhost
    access_log /var/log/nginx/subdomain.example.com-access.log;
    error_log  /var/log/nginx/subdomain.example.com-error.log error;

    # Make site accessible from http://localhost/
    server_name subdomain.example.com;

    # Specify a character set
    charset utf-8;

    # Don't log robots.txt or favicon.ico files
    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    # 404 errors handled by our application
    error_page 404 /index.html;

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
              root /usr/share/nginx/www;
    }

    # Deny access to .htaccess
    location ~ /\.ht {
            deny all;
    }        

# Define default caching of 24h
    expires 86400s;
    add_header Pragma public;
    add_header Cache-Control "max-age=86400, public, must-revalidate, proxy-revalidate";

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
