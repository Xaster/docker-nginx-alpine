FROM alpine:latest as build

RUN cd \
    && apk upgrade --no-cache \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        curl \
        git \
        wget \
        sed \
        gperf \
        icu-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        py-setuptools \
        pcre-dev \
        bash \
        util-linux-dev \
        expat-dev \
        openssl-dev \
        linux-headers \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        jemalloc-dev \
        gettext-dev \
    && APR_VERSION=$(curl -sS --fail http://apr.apache.org/download.cgi | \
        grep -o '/apr/apr-[a-zA-Z0-9.]*[.]tar[.]bz2' | \
        sed -e 's~^/apr/apr-~~' -e 's~\.tar\.bz2$~~' | \
        sed '/alpha.*/Id' | \
        sed '/pre.*/Id' | \
        sed '/beta.*/Id' | \
        sed '/rc.*/Id' | \
        sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
        tail -n 1) \
    && APR_UTIL_VERSION=$(curl -sS --fail http://apr.apache.org/download.cgi | \
        grep -o '/apr/apr-util-[a-zA-Z0-9.]*[.]tar[.]bz2' | \
        sed -e 's~^/apr/apr-util-~~' -e 's~\.tar\.bz2$~~' | \
        sed '/alpha.*/Id' | \
        sed '/pre.*/Id' | \
        sed '/beta.*/Id' | \
        sed '/rc.*/Id' | \
        sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
        tail -n 1) \
    && HTTPD_VERSION=$(curl -sS --fail http://httpd.apache.org/download.cgi | \
        grep -o '/httpd/httpd-[a-zA-Z0-9.]*[.]tar[.]bz2' | \
        sed -e 's~^/httpd/httpd-~~' -e 's~\.tar\.bz2$~~' | \
        sed '/alpha.*/Id' | \
        sed '/pre.*/Id' | \
        sed '/beta.*/Id' | \
        sed '/rc.*/Id' | \
        sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
        tail -n 1) \
    && NPS_VERSION=$(curl -sS --fail https://github.com/apache/incubator-pagespeed-ngx/releases | \
        grep -o '/incubator-pagespeed-ngx/archive/v[a-zA-Z0-9.]*-stable[.]tar[.]gz' | \
        sed -e 's~^/incubator-pagespeed-ngx/archive/v~~' -e 's~\-stable\.tar\.gz$~~' | \
        sed '/alpha.*/Id' | \
        sed '/pre.*/Id' | \
        sed '/beta.*/Id' | \
        sed '/rc.*/Id' | \
        sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
        tail -n 1) \
    && NCP_VERSION=$(curl -sS --fail https://github.com/FRiCKLE/ngx_cache_purge/releases | \
        grep -o '/ngx_cache_purge/archive/[a-zA-Z0-9.]*[.]tar[.]gz' | \
        sed -e 's~^/ngx_cache_purge/archive/~~' -e 's~\.tar\.gz$~~' | \
        sed '/alpha.*/Id' | \
        sed '/pre.*/Id' | \
        sed '/beta.*/Id' | \
        sed '/rc.*/Id' | \
        sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
        tail -n 1) \
    && NGINX_VERSION=$(curl -sS --fail https://nginx.org/en/download.html | \
        grep -o '/download/nginx-[a-zA-Z0-9.]*[.]tar[.]gz' | \
        sed -e 's~^/download/nginx-~~' -e 's~\.tar\.gz$~~' | \
        sed '/alpha.*/Id' | \
        sed '/pre.*/Id' | \
        sed '/beta.*/Id' | \
        sed '/rc.*/Id' | \
        sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
        tail -n 1) \
    && wget --no-check-certificate https://www-us.apache.org/dist//apr/apr-${APR_VERSION}.tar.bz2 \
    && wget --no-check-certificate https://www-us.apache.org/dist//apr/apr-util-${APR_UTIL_VERSION}.tar.bz2 \
    && wget --no-check-certificate https://www-us.apache.org/dist//httpd/httpd-${HTTPD_VERSION}.tar.bz2 \
    && wget --no-check-certificate https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}-stable.tar.gz \
    && wget --no-check-certificate https://github.com/FRiCKLE/ngx_cache_purge/archive/${NCP_VERSION}.tar.gz \
    && wget --no-check-certificate https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    && tar -xjvf apr-${APR_VERSION}.tar.bz2 \
    && tar -xjvf apr-util-${APR_UTIL_VERSION}.tar.bz2 \
    && tar -xjvf httpd-${HTTPD_VERSION}.tar.bz2 \
    && tar -xvzf v${NPS_VERSION}-stable.tar.gz \
    && tar -xvzf ${NCP_VERSION}.tar.gz \
    && tar -xvzf nginx-${NGINX_VERSION}.tar.gz \
    && mv -f apr-${APR_VERSION} apr \
    && mv -f apr-util-${APR_UTIL_VERSION} apr-util \
    && mv -f httpd-${HTTPD_VERSION} httpd \
    && mv -f incubator-pagespeed-ngx-${NPS_VERSION}-stable ngx_pagespeed \
    && mv -f ngx_cache_purge-${NCP_VERSION} ngx_cache_purge \
    && mv -f nginx-$NGINX_VERSION nginx \
    && git clone -b v${NPS_VERSION} \
        --recurse-submodules \
        --depth=1 \
        -c advice.detachedHead=false \
        -j`nproc` \
        https://github.com/apache/incubator-pagespeed-mod.git \
        modpagespeed \
    && git clone \
        -j`nproc` \
        https://github.com/google/ngx_brotli \
        ngx_brotli \
    && cd $HOME/ngx_brotli \
    && git submodule update --init \
    && cd $HOME/apr \
    && ./configure --prefix=/usr/local \
    && make -j`nproc` \
    && make install -j`nproc` \
    && cd $HOME/apr-util \
    && ./configure --prefix=/usr/local --with-apr=/usr/local \
    && make -j`nproc` \
    && make install -j`nproc` \
    && cd $HOME/httpd \
    && ./configure --prefix=/usr/local --with-apr=/usr/local --with-apr-util=/usr/local \
    && make -j`nproc` \
    && make install -j`nproc` \
    && cd $HOME/modpagespeed \
    && wget --no-check-certificate https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/modpagespeed/automatic_makefile.patch \
    && wget --no-check-certificate https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/modpagespeed/libpng16.patch \
    && wget --no-check-certificate https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/modpagespeed/pthread_nonrecursive_np.patch \
    && wget --no-check-certificate https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/modpagespeed/rename_c_symbols.patch \
    && wget --no-check-certificate https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/modpagespeed/stack_trace_posix.patch \
    && for i in *.patch; do printf "\r\nApplying patch ${i%%.*}\r\n"; patch -p1 < $i || exit 1; done \
    && cd $HOME/modpagespeed/tools/gyp \
    && ./setup.py install \
    && cd $HOME/modpagespeed \
    && build/gyp_chromium --depth=. \
        -D use_system_libs=1 \
        -D system_include_path_apr=/usr/local/include/apr-1 \
        -D system_include_path_aprutil=/usr/local/include/apr-1 \
        -D system_include_path_httpd=/usr/local/include \
    && cd $HOME/modpagespeed/pagespeed/automatic \
    && make psol BUILDTYPE=Release \
        CFLAGS+="-I/usr/local/include/apr-1" \
        CXXFLAGS+="-I/usr/local/include/apr-1 -DUCHAR_TYPE=uint16_t" \
        -j`nproc` \
    && mkdir -p $HOME/ngx_pagespeed/psol/lib/Release/linux/x64 \
    && mkdir -p $HOME/ngx_pagespeed/psol/include/out/Release \
    && cd $HOME/modpagespeed \
    && cp -rf out/Release/obj $HOME/ngx_pagespeed/psol/include/out/Release/ \
    && cp -rf pagespeed/automatic/pagespeed_automatic.a $HOME/ngx_pagespeed/psol/lib/Release/linux/x64/ \
    && cp -rf net \
        pagespeed \
        testing \
        third_party \
        url \
        $HOME/ngx_pagespeed/psol/include/ \
    && cd $HOME/nginx \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/run/nginx/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-threads \
        --with-stream=dynamic \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
        --with-http_slice_module \
        --with-mail=dynamic \
        --with-mail_ssl_module \
        --with-compat \
        --with-file-aio \
        --with-http_v2_module \
        --add-module=$HOME/ngx_cache_purge \
        --add-dynamic-module=$HOME/ngx_brotli \
        --add-dynamic-module=$HOME/ngx_pagespeed \
        --with-ld-opt='-ljemalloc -Wl,-z,relro,--start-group -licuuc -lapr-1 -laprutil-1 -lpng -ljpeg' \
    && make -j`nproc` \
    && make install -j`nproc` \
    && cd \
    && rm -rf \
        /etc/nginx/nginx.conf \
        /etc/nginx/nginx.conf.default \
        /etc/nginx/uwsgi_params.default \
        /etc/nginx/scgi_params.default \
        /etc/nginx/mime.types.default \
        /etc/nginx/fastcgi_params.default \
        /etc/nginx/fastcgi.conf.default \
    && mkdir -p /etc/nginx/conf.d/ \
    && mkdir -p /etc/nginx/extra/ \
    && strip /usr/sbin/nginx* \
    && strip /usr/lib/nginx/modules/*.so \
    && mv -f /usr/bin/envsubst /usr/bin/envsubst_default \
    && apk del .build-deps \
    && rm -rf \
        $HOME/* \
        /usr/local/*

FROM alpine:latest

COPY --from=build /usr/bin/envsubst_default /usr/bin/envsubst
COPY --from=build /etc/nginx/html/ /usr/share/nginx/html_default/
COPY --from=build /etc/nginx/ /etc/nginx_default/
COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
COPY --from=build /usr/lib/nginx/modules/ /usr/lib/nginx/modules/

RUN apk upgrade --no-cache \
    && RUN_DEPS=$(scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /usr/bin/envsubst | \
        tr ',' '\n' | \
        sort -u | \
        awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') \
    && apk add --no-cache $RUN_DEPS tzdata \
    && wget --no-check-certificate -O /etc/nginx_default/nginx.conf https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/nginx/nginx.conf \
    && wget --no-check-certificate -O /etc/nginx_default/conf.d/default.conf https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/nginx/default.conf \
    && wget --no-check-certificate -O /etc/nginx_default/extra/pagespeed.conf https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/nginx/pagespeed.conf \
    && wget --no-check-certificate -O /etc/nginx_default/extra/cache_purge.conf https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/nginx/cache_purge.conf \
    && wget --no-check-certificate -O /etc/nginx_default/extra/brotli.conf https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/nginx/brotli.conf \
    && wget --no-check-certificate -O /usr/bin/CMD-Shell https://raw.githubusercontent.com/Xaster/docker-nginx-alpine/master/CMD-Shell \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && mkdir -p /usr/share/nginx/html \
    && mkdir -p /etc/nginx \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/run/nginx \
    && mkdir -p /etc/certs \
    && chown -R nginx:nginx /usr/share/nginx/html \
    && chmod +x /usr/bin/CMD-Shell \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/usr/share/nginx/html", "/etc/nginx", "/etc/certs", "/var/log/nginx", "/var/cache/nginx", "/var/run/nginx"]
EXPOSE 80 443
ENV TIMEZONE=""

CMD ["CMD-Shell"]
