#!/bin/sh
test -f '/etc/nginx/fastcgi.conf' || cp /etc/nginx_default/fastcgi.conf /etc/nginx/fastcgi.conf
test -f '/etc/nginx/fastcgi.conf.default' || cp /etc/nginx_default/fastcgi.conf /etc/nginx/fastcgi.conf.default
test -f '/etc/nginx/fastcgi_params' || cp /etc/nginx_default/fastcgi_params /etc/nginx/fastcgi_params
test -f '/etc/nginx/fastcgi_params.default' || cp /etc/nginx_default/fastcgi_params /etc/nginx/fastcgi_params.default
test -f '/etc/nginx/mime.types' || cp /etc/nginx_default/mime.types /etc/nginx/mime.types
test -f '/etc/nginx/mime.types.default' || cp /etc/nginx_default/mime.types /etc/nginx/mime.types.default
test -f '/etc/nginx/nginx.conf' || cp /etc/nginx_default/nginx.conf /etc/nginx/nginx.conf
test -f '/etc/nginx/nginx.conf.default' || cp /etc/nginx_default/nginx.conf /etc/nginx/nginx.conf.default
test -f '/etc/nginx/scgi_params' || cp /etc/nginx_default/scgi_params /etc/nginx/scgi_params
test -f '/etc/nginx/scgi_params.default' || cp /etc/nginx_default/scgi_params /etc/nginx/scgi_params.default
test -f '/etc/nginx/uwsgi_params' || cp /etc/nginx_default/uwsgi_params /etc/nginx/uwsgi_params
test -f '/etc/nginx/uwsgi_params.default' || cp /etc/nginx_default/uwsgi_params /etc/nginx/uwsgi_params.default
test -f '/etc/nginx/win-utf' || cp /etc/nginx_default/win-utf /etc/nginx/win-utf
test -f '/etc/nginx/koi-utf' || cp /etc/nginx_default/koi-utf /etc/nginx/koi-utf
test -f '/etc/nginx/koi-win' || cp /etc/nginx_default/koi-win /etc/nginx/koi-win
test -d '/etc/nginx/conf.d' || mkdir /etc/nginx/conf.d
test -d '/etc/nginx/extra' || mkdir /etc/nginx/extra
test -f '/etc/nginx/conf.d/default.conf.default' || cp /etc/nginx_default/conf.d/default.conf /etc/nginx/conf.d/default.conf.default
test -f '/etc/nginx/extra/pagespeed.conf' || cp /etc/nginx_default/extra/pagespeed.conf /etc/nginx/extra/pagespeed.conf
test -f '/etc/nginx/extra/pagespeed.conf.default' || cp /etc/nginx_default/extra/pagespeed.conf /etc/nginx/extra/pagespeed.conf.default
test -f '/etc/nginx/extra/cache_purge.conf' || cp /etc/nginx_default/extra/cache_purge.conf /etc/nginx/extra/cache_purge.conf
test -f '/etc/nginx/extra/cache_purge.conf.default' || cp /etc/nginx_default/extra/cache_purge.conf /etc/nginx/extra/cache_purge.conf.default
test -f '/etc/nginx/extra/brotli.conf' || cp /etc/nginx_default/extra/brotli.conf /etc/nginx/extra/brotli.conf
test -f '/etc/nginx/extra/brotli.conf.default' || cp /etc/nginx_default/extra/brotli.conf /etc/nginx/extra/brotli.conf.default
if [ $TIMEZONE ]; then
  rm -rf /etc/localtime
  echo "${TIMEZONE}" > /etc/TZ
  cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
fi
find /etc/nginx/conf.d -name "*.conf" | grep -q ".conf"
if [ $? -ne 0 ];then
  cp /etc/nginx_default/conf.d/default.conf /etc/nginx/conf.d/default.conf
fi
find /usr/share/nginx/html -name "index.*" | grep -q "index."
if [ $? -ne 0 ];then
  cp /usr/share/nginx/html_default/index.html /usr/share/nginx/html/index.html
  cp /usr/share/nginx/html_default/50x.html /usr/share/nginx/html/50x.html
fi
/usr/sbin/nginx -g 'daemon off;'
