server {
    listen 8080;
        #root /usr/share/nginx/html;
        root /var/www/example.com;

        # Tell the browser about SPDY
        # add_header  Alternate-Protocol 443:npn-spdy/2;

        index index.php index.html index.htm;

        # Make site accessible from http://localhost/
        server_name example.com;

        autoindex off;
        location /app/                { deny all; }
        location /includes/           { deny all; }
        location /lib/                { deny all; }
        location /media/downloadable/ { deny all; }
        location /pkginfo/            { deny all; }
        location /report/config.xml   { deny all; }
        location /var/                { deny all; }
        location = /RELEASE_NOTES.txt { deny all; }
        location = /LICENSE_AFL.txt   { deny all; }
        location = /LICENSE.html      { deny all; }
        location = /LICENSE.txt       { deny all; }
        location = /php.ini.sample    { deny all; }
        location = /index.php.sample  { deny all; }
        location  /.                  { return 404; }

        location ~* \.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
               access_log off;
               expires 30d;
        }

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        try_files $uri $uri/ /index.php?q=$uri&$args;    # /index.html;
        # Uncomment to enable naxsi on this location
        # include /etc/nginx/naxsi.rules

        if ($request_uri ~* "\.(png|gif|jpg|jpeg|css|js|swf|ico|txt|xml|bmp|pdf|doc|docx|ppt|pptx|zip)$") {
        expires max;
        }

    }

    # Only for nginx-naxsi used with nginx-naxsi-ui : process denied requests
    #location /RequestDenied {
    #   proxy_pass http://127.0.0.1:8080;
    #}

    error_page 404 /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php$ {
            try_files $uri = 404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
        # NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini

        expires        off; # Do not cache dynamic content

        # With php5-cgi alone:
        #fastcgi_pass 127.0.0.1:9000;
        # With php5-fpm:
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
                fastcgi_param  QUERY_STRING     $query_string;
                fastcgi_param  REQUEST_METHOD   $request_method;
                fastcgi_param  CONTENT_TYPE     $content_type;
                fastcgi_param  CONTENT_LENGTH   $content_length;
                fastcgi_intercept_errors        on;
                fastcgi_ignore_client_abort     off;
                fastcgi_connect_timeout 60;
                fastcgi_send_timeout 180;
                fastcgi_read_timeout 180;
                fastcgi_buffer_size 128k;
                fastcgi_buffers 4 256k;
                fastcgi_busy_buffers_size 256k;
                fastcgi_temp_file_write_size 256k;
    }

        rewrite ^/sitemap_index\.xml$ /index.php?sitemap=1 last;
        rewrite ^/([^/]+?)-sitemap([0-9]+)?\.xml$ /index.php?sitemap=$1&sitemap_n=$2 last;
        # rewrite ^(.*) https://$host$1 permanent;
}

# HTTPS server

#server {
#        listen 443 spdy;
#        server_name example.com;
#
#        root /var/www/example.com;
#        index index.php index.html index.htm;
#
#        ssl on;
#        # SSL Certificate and private key
#        ssl_certificate /etc/nginx/ssl/example.com.crt;
#        ssl_certificate_key /etc/nginx/ssl/example.com_encrypted.key;
#        example.com.csr  example.com_encrypted.key
#        # Tell the browser about SPDY
#        add_header  Alternate-Protocol 443:npn-spdy/2;
#}
