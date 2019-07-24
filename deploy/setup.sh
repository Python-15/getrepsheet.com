#!/usr/bin/env bash

apt-get -y update
apt-get -y upgrade
apt-get -y install curl g++ gcc make cmake pkg-config libhiredis0.13 libhiredis-dev libpcre3-dev zlib1g-dev luarocks redis wget gpg software-properties-common openssl libssl-dev

wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add -
add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"
apt-get -y update
apt-get -y install --no-install-recommends openresty

export NGINX_VERSION=1.16.0
export REPSHEET_VERSION=5.1.0
export BOT_VERIFIER_VERSION=0.0.10
export WEBSITE_VERSION=1.0.0
export REDIS_MODULE_VERSION=0.0.5
export VISUALIZER_VERSION=3.0.5

curl -s -L -O "https://github.com/repsheet/redis_module/archive/${REDIS_MODULE_VERSION}.tar.gz"
tar xzf ${REDIS_MODULE_VERSION}.tar.gz
pushd redis_module-${REDIS_MODULE_VERSION}
make
cp repsheet.so /etc/redis/
echo "loadmodule /etc/redis/repsheet.so" >> /etc/redis/redis.conf
popd

curl -s -L -O "https://github.com/repsheet/visualizer/archive/${VISUALIZER_VERSION}.tar.gz"
tar xzf ${VISUALIZER_VERSION}.tar.gz
pushd visualizer-${VISUALIZER_VERSION}
cp nginx.conf /usr/local/openresty/nginx/conf/
cp -r src/lua /usr/local/openresty/nginx/conf/
cp -r src/html/* /usr/local/openresty/nginx/html/
popd

curl -s -L -O "https://github.com/repsheet/repsheet-nginx/archive/${REPSHEET_VERSION}.tar.gz"
tar xzf ${REPSHEET_VERSION}.tar.gz

curl -s -L -O "https://github.com/abedra/ngx_bot_verifier/archive/v${BOT_VERIFIER_VERSION}.tar.gz"
tar xzf v${BOT_VERIFIER_VERSION}.tar.gz

curl -s -L -O "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
tar xzf nginx-${NGINX_VERSION}.tar.gz
pushd nginx-${NGINX_VERSION}
./configure --with-http_ssl_module --add-module=../repsheet-nginx-${REPSHEET_VERSION} --add-module=../ngx_bot_verifier-${BOT_VERIFIER_VERSION}
make
make install
popd

curl -s -L -O "https://github.com/repsheet/getrepsheet.com/archive/${WEBSITE_VERSION}.tar.gz"
tar xzf ${WEBSITE_VERSION}.tar.gz
cp -r getrepsheet.com-${WEBSITE_VERSION}/* /usr/local/nginx/html/

mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.orig
mv nginx.conf /usr/local/nginx/conf/nginx.conf
mv www_* /etc/ssl/certs
mv nginx.service /etc/systemd/system/
