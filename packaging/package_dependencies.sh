#!/bin/bash

##Script is untested.
sudo apt-get update
sudo apt-get install gcc ruby-dev make
sudo gem install fpm

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
pushd $SCRIPTDIR

###openresty
wget https://openresty.org/download/ngx_openresty-1.9.7.1.tar.gz
tar -xzvf ngx_openresty-1.9.7.1.tar.gz
rm -f ngx_openresty-*.tar.gz

SOURCE=$SCRIPTDIR/ngx_openresty-1.9.7.1
cd $SOURCE
mkdir -p $SOURCE/build
mkdir -p $SOURCE/build/root

./configure --with-pcre-jit \
    --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx.pid \
    --user=nginx --prefix=/usr/share/nginx \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log --sbin-path=/usr/sbin/nginx \
    --lock-path=/var/lock/nginx.lock \
    --http-proxy-temp-path=/var/lib/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/lib/nginx/scgi_temp \
    --http-client-body-temp-path=/var/lib/nginx/client_body_temp -j4
make
make install DESTDIR=$SOURCE/build/root

###Don't modify VERSION and ARCH. They will be automatically filled by fpm
fpm -s dir -t deb -n openresty -v 1.9.7.1 -C $SOURCE/build/root -p $SCRIPTDIR/openresty_VERSION_ARCH.deb \
    --description "a high performance web server and a reverse proxy server with Openresty extensions"  \
    --url 'http://openresty.org/' -m 'OpenResty Team' --vendor "Amalgam8 Team" \
    --category httpd \
    -d libncurses5 -d libssl1.0.0 -d libreadline6 -d libpcre3 -d unzip -d curl \
    --replaces 'nginx-full' --provides 'nginx-full' --conflicts 'nginx-full' \
    --replaces 'nginx-common' --provides 'nginx-common' --conflicts 'nginx-common' \
    --replaces 'nginx-core' --provides 'nginx-core' --conflicts 'nginx-core' \
    --after-install $SCRIPTDIR/openresty_post_install.sh \
    --deb-build-depends build-essential
popd

pushd $SCRIPTDIR
###sidecar
SOURCE=../$SCRIPTDIR
cd $SOURCE
make
make release
fpm -s dir -t deb -n a8sidecar -v 0.1.0 -C $SOURCE/dist \
    -p $SOURCE/release/a8sidecar_VERSION_ARCH.deb \
    --description "Amalgam8 Sidecar"  --url 'https://amalgam8.io' \
    -m 'Amalgam8 Team' --vendor "Amalgam8 Team" --category httpd \
    -d filebeat -d openresty
cp $SCRIPTDIR/openresty_1.9.7.1_amd64.deb $SOURCE/release/
cp $SCRIPTDIR/install-a8sidecar-v0.1.0.sh $SOURCE/release/install-a8sidecar.sh
popd

##installing debs in docker container
###install-a8sidecar.sh
##curl -sSL https://github.com/amalgam8/sidecar/releases/download/v0.1.0/install-a8sidecar.sh | sh
