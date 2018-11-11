# docker-nginx-alpine
Docker: Nginx With All Official Modules And Some Third Party Modules (Based On Alpine)

# Third Party Modules
```
Jemalloc (Share Library)
OpenSSL (Just Build Into The Nginx)
Nginx Module:Cache-Purge
Nginx Module:Brotli
Nginx Module:PageSpeed
```

# Usage
```
$ docker pull xaster/docker-nginx-alpine

$ docker run -d \
    --name docker-nginx-alpine \
    -v /WEB_DIR:/usr/share/nginx/html \
    -v /CONFIG_DIR:/etc/nginx \
    -v /CERTS_DIR:/etc/certs \
    -v /LOG_DIR:/var/log/nginx \
    -v /CACHE_DIR:/var/cache/nginx \
    -v /PID_DIR:/var/run/nginx \
    -p 80:80 \
    -p 443:443 \
    -e TIMEZONE=YOUR_TIME_ZONE \
    xaster/docker-nginx-alpine
```
