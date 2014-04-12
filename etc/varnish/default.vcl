# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
# 
# Default backend definition.  Set this to point to your content
# server.
# 
backend default {
.host = "127.0.0.1";
.port = "8080";
.connect_timeout = 600s;
.first_byte_timeout = 600s;
.between_bytes_timeout = 600s;
.max_connections = 800;

}
# Drop any cookies sent to WordPress.
sub vcl_recv {
    if (!(req.url ~ "wp-(login|admin)")) {
        unset req.http.cookie;
    }
}

# Drop any cookies WordPress tries to send back to the client.
sub vcl_fetch {
    if (!(req.url ~ "wp-(login|admin)")) {
        unset beresp.http.set-cookie;
    }
}


acl purge {
      "localhost";
}

sub vcl_recv {
        if (req.request == "PURGE") {
                if (!client.ip ~ purge) {
                        error 405 "Not allowed.";
                }
                return(lookup);
        }
if (req.url ~ "^/$") {
               unset req.http.cookie;
            }
}
sub vcl_hit {
        if (req.request == "PURGE") {
                set obj.ttl = 0s;
                error 200 "Purged.";
        }
}
sub vcl_miss {
        if (req.request == "PURGE") {
                error 404 "Not in cache.";
        }
if (!(req.url ~ "wp-(login|admin)")) {
                        unset req.http.cookie;
                }
    if (req.url ~ "^/[^?]+.(jpeg|jpg|png|gif|ico|js|css|txt|gz|zip|lzma|bz2|tgz|tbz|html|htm)(\?.|)$") {
       unset req.http.cookie;
       set req.url = regsub(req.url, "\?.$", "");
    }
    if (req.url ~ "^/$") {
       unset req.http.cookie;
    }
}
sub vcl_fetch {
        if (req.url ~ "^/$") {
                unset beresp.http.set-cookie;
        }
if (!(req.url ~ "wp-(login|admin)")) {
                        unset beresp.http.set-cookie;
}

set req.grace = 2m;

# Set X-Forwarded-For header for logging in nginx
remove req.http.X-Forwarded-For;
set    req.http.X-Forwarded-For = client.ip;

# Remove has_js and CloudFlare/Google Analytics __* cookies.
set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(_[_a-z]+|has_js)=[^;]*", "");
# Remove a ";" prefix, if present.
set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");

# Remove the wp-settings-1 cookie
set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-1=[^;]+(; )?", "");

# Remove the wp-settings-time-1 cookie
set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-time-1=[^;]+(; )?", "");

# Remove the wp test cookie
set req.http.Cookie = regsuball(req.http.Cookie, "wordpress_test_cookie=[^;]+(; )?", "");

# Static content unique to the theme can be cached (so no user uploaded images)
# The reason I don't take the wp-content/uploads is because of cache size on bigger blogs
# that would fill up with all those files getting pushed into cache
if (req.url ~ "wp-content/themes/" && req.url ~ "\.(css|js|png|gif|jp(e)?g)") {
    unset req.http.cookie;
}
}

sub vcl_fetch {
	#set obj.grace = 5m;
    set beresp.grace = 2m;

}

sub vcl_hit {
        if (req.request == "PURGE") {
                purge;
                error 200 "Purged.";
        }
}

sub vcl_miss {
        if (req.request == "PURGE") {
                purge;
                error 200 "Purged.";
        }
}
