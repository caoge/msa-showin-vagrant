#!/usr/bin/env bash
echo ">>> Checking PHP"

if [ ! -d "/data/logs/php" ]; then
    sudo mkdir -p /data/logs/php
fi

if [ ! -f "/data/app/php7.1/bin/php" ]; then

    echo ">>> Installing PHP"

    cd /data/src

    if [ ! -f "php-7.1.4.tar.gz" ]; then
        echo ">>> Downloading php-7.1.4"
        sudo wget -q http://cn2.php.net/distributions/php-7.1.4.tar.gz

    fi

    if [ ! -d "php-7.1.4" ]; then
        tar -zxf php-7.1.4.tar.gz
    fi

    cd php-7.1.4

    make clean

    sudo ./configure --prefix=/data/app/php7.1 \
    	--with-config-file-path=/data/app/php7.1/lib \
    	--with-config-file-scan-dir=/data/app/php7.1/lib/conf.d \
    	--with-zlib \
    	--with-gettext \
    	--with-curl \
    	--with-gd \
    	--with-freetype-dir \
    	--with-openssl \
    	--with-xmlrpc \
    	--with-pdo-mysql \
    	--enable-ftp \
    	--enable-exif \
    	--enable-shmop \
    	--enable-sysvmsg \
    	--enable-sysvsem \
    	--enable-sysvshm \
    	--enable-xml \
    	--enable-bcmath \
    	--enable-mbregex \
    	--enable-mbstring \
    	--enable-pcntl \
    	--enable-sockets \
    	--enable-zip \
    	--enable-soap \
    	--enable-pdo \
    	--enable-fpm

    make && make install

    cp php.ini-development /data/app/php7.1/lib/php.ini

    cp /data/app/php7.1/etc/php-fpm.conf.default /data/app/php7.1/etc/php-fpm.conf
	cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
	chmod +x /etc/init.d/php-fpm

	sudo sed -i "s/display_errors = .*/display_errors = On/" /data/app/php7.1/lib/php.ini
	sudo sed -i "s|;date.timezone =|date.timezone = \"Asia/Shanghai\"|g" /data/app/php7.1/lib/php.ini
	sudo sed -i "s/;error_log = php_errors.log/error_log = \/data\/logs\/php\/errors.log/" /data/app/php7.1/lib/php.ini

	# fpm配置
	sudo sed -i "s/;request_slowlog_timeout = 0/request_slowlog_timeout = 5/" /data/app/php7.1/etc/php-fpm.conf
	sudo sed -i "s/;slowlog = .*/slowlog = \/data\/logs\/php\/\$pool.log.slow/" /data/app/php7.1/etc/php-fpm.conf
	sudo sed -i "s/user = nobody/user = www/" /data/app/php7.1/etc/php-fpm.conf
	sudo sed -i "s/group = nobody/group = www/" /data/app/php7.1/etc/php-fpm.conf
	sudo sed -i "s/include=/;include=/" /data/app/php7.1/etc/php-fpm.conf

	ln -s /data/app/php7.1/bin/pear /usr/local/bin/pear
	ln -s /data/app/php7.1/bin/peardev /usr/local/bin/peardev
	ln -s /data/app/php7.1/bin/pecl /usr/local/bin/pecl
	ln -s /data/app/php7.1/bin/phar /usr/local/bin/phar
	ln -s /data/app/php7.1/bin/phar.phar /usr/local/bin/phar.phar
	ln -s /data/app/php7.1/bin/php /usr/local/bin/php
	ln -s /data/app/php7.1/bin/php-cgi /usr/local/bin/php-cgi
	ln -s /data/app/php7.1/bin/php-config /usr/local/bin/php-config
	ln -s /data/app/php7.1/bin/phpize /usr/local/bin/phpize

    sudo ln -s /data/app/php7.1/bin/phpize /bin/phpize
    sudo ln -s /data/app/php7.1/bin/php /bin/php
    sudo ln -s /data/app/php7.1/bin/php-cgi /bin/php-cgi
    sudo ln -s /data/app/php7.1/bin/php-config /bin/php-config

    echo ">>> Installing PHP Success"
fi

if [ ! -d "/data/app/php7.1/lib/conf.d" ]; then
    sudo mkdir /data/app/php7.1/lib/conf.d
fi

# phalcon3扩展
echo ">>> Checking Phalcon3 Extension"
cd /data/src
if [ ! -f "v3.1.2.tar.gz" ]; then
    wget -q https://github.com/phalcon/cphalcon/archive/v3.1.2.tar.gz
fi

if [ ! -d "cphalcon-3.1.2" ]; then
    tar -zxf v3.1.2.tar.gz

    cd cphalcon-3.1.2/build
    sudo ./install --phpize /usr/local/bin/phpize --php-config /usr/local/bin/php-config
    echo "extension=phalcon.so" > /data/app/php7.1/lib/conf.d/ext-phalcon.ini
fi

# swoole扩展
echo ">>> Checking Swoole Extension"
cd /data/src

if [ ! -f "v2.0.7.tar.gz" ]; then
    wget -q https://github.com/swoole/swoole-src/archive/v2.0.7.tar.gz

fi

if [ ! -d "swoole-src-2.0.7" ]; then
    tar -zxf v2.0.7.tar.gz

    cd swoole-src-2.0.7
    phpize && ./configure && make && make install
    echo -e "extension=swoole.so\nswoole.use_namespace=On" > /data/app/php7.1/lib/conf.d/ext-swoole.ini
fi

# xdebug扩展
echo ">>> Checking Xdebug Extension"
cd /data/src
if [ ! -d "xdebug" ]; then
    git clone git://github.com/xdebug/xdebug.git

    cd xdebug
    phpize && ./configure && make && make install
    echo -e "zend_extension=xdebug.so" > /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.remote_enable=1" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.remote_host=$(echo $SSH_CLIENT | awk '{print $1}')" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.remote_port=9000" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.max_nesting_level=200" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.idekey=\"PHPSTORM\"" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.remote_autostart=1" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
fi

if [ $(grep -c "" /data/app/php7.1/lib/conf.d/ext-xdebug.ini) != 7 ]; then
    echo -e "zend_extension=xdebug.so" > /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.remote_enable=1" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.remote_host=$(echo $SSH_CLIENT | awk '{print $1}')" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.remote_port=9000" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.max_nesting_level=200" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.idekey=\"PHPSTORM\"" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
    echo -e "xdebug.remote_autostart=1" >> /data/app/php7.1/lib/conf.d/ext-xdebug.ini
fi

cp /data/www/msa-showin-vagrant/templates/xdebug/xdebug.sh /etc/profile.d
source /etc/profile

echo ">>> Checking PHP End"