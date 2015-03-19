FROM ubuntu:trusty

ADD nginx-push-stream-module /src/nginx-push-stream-module
ADD nginx /src/nginx

RUN apt-get update
RUN \
  dpkg --get-selections | grep -v deinstall | awk '{print $1}' | sort > /tmp/initial-packages && \
  DEBIAN_FRONTEND=noninteractive apt-get -y build-dep nginx && \
  cd /src/nginx && \
  ./configure --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' \
  --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf \
  --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock \
  --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
  --with-debug --with-pcre-jit --with-ipv6 --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module \
  --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module \
  --with-http_image_filter_module --with-http_spdy_module --with-http_sub_module --with-http_xslt_module --with-mail \
  --with-mail_ssl_module --add-module=../nginx-push-stream-module && \
  make && \
  cd /src/nginx && \
  make install && \
  dpkg --get-selections | grep -v deinstall | awk '{print $1}' | sort > /tmp/final-packages && \
  DEBIAN_FRONT_END=noninteractive apt-get -y purge `comm -13 /tmp/initial-packages /tmp/final-packages`

CMD /usr/sbin/nginx -g 'daemon off;'
EXPOSE 80
EXPOSE 443
