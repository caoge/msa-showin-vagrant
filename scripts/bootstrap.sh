#!/usr/bin/env bash
# 创建项目文件夹
if [ ! -d "/data" ]; then
    mkdir /data
fi

# 下载软件目录
if [ ! -d "/data/src" ]; then
    mkdir /data/src
fi

yum -y install wget vim git pcre pcre-devel zlib zlib-devel openssl openssl-devel libxml2 libxml2-devel libcurl libcurl-devel \
		libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libtool gcc-c++

cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 最新版git
#yum -y install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker gettext gettext-devel
#sudo wget -q https://github.com/git/git/archive/v2.12.0.tar.gz
#sudo tar -zxvf v2.12.0.tar.gz
#cd git-2.12.0/
#sudo make
#sudo make install

#sudo wget https://github.com/skvadrik/re2c/archive/0.16.tar.gz
#sudo tar -zxvf 0.16.tar.gz
#cd re2c-0.16/re2c/
#sudo ./autogen.sh
#sudo ./configure
#sudo make
#sudo make install