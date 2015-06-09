#!/usr/bin/env bash

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

apt-get -y install \
  git \
  htop \
  mysql-client \
  mysql-server \
  nginx \
  php5-cli \
  php5-curl \
  php5-fpm \
  php5-gd \
  php5-mcrypt \
  php5-mysql \
  php5-redis \
  php5-xdebug \
  redis-server \
  redis-tools

echo 'server {
  listen 80;
  server_name ~^(.+)\.192\.168\.50\.101\.xip\.io;
  set $project $1;
  root /var/www/html/$project;
  location / {
    index index.html index.php;
  }
  location ~ .php$ {
    expires        off;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
    include        fastcgi_params;
  }
}
' > /etc/nginx/conf.d/vhost.conf

echo '
[xdebug]
xdebug.default_enable=1
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_host=localhost
xdebug.remote_port=9000
xdebug.remote_autostart=1
xdebug.profiler_enable_trigger=1' >> /etc/php5/fpm/php.ini

cd ~
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -zxvf ioncube_loaders_lin_x86-64.tar.gz
mv ioncube/ioncube_loader_lin_5.5.so /usr/lib/php5/
rm -rf ioncube ioncube_loaders_lin_x86-64.tar.gz

sed -i "1i\\
zend_extension=/usr/lib/php5/ioncube_loader_lin_5.5.so" /etc/php5/fpm/php.ini

sed -i "880i\\
date.timezone = 'America/Los_Angeles'" /etc/php5/fpm/php.ini

echo '
max_allowed_packet=1G
innodb_log_buffer_size=1G
innodb_file_per_table' >> /etc/mysql/my.cnf

sed -i "48i\\
bind-address            = 192.168.50.101" /etc/mysql/my.cnf

ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/fpm/conf.d/20-mcrypt.ini
ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini

service nginx restart
service php5-fpm restart
service mysql restart
redis-server /etc/redis/redis.conf 

echo 'redis-server /etc/redis/redis.conf' > /etc/rc.local

echo '[client]
user=root
password=root' > ~/.my.cnf

cd ~

curl -sS https://getcomposer.org/installer | php
chmod +x composer.phar
mv composer.phar /usr/local/bin/composer

git clone https://github.com/netz98/n98-magerun.git
cd n98-magerun
/usr/local/bin/composer install
cd /usr/local/bin
ln -s ~/n98-magerun/bin/n98-magerun magerun

echo '
alias ls="ls -ahF --color=auto"
alias ll="ls -l"
alias grep="grep --color=auto"
__cur_dir() {
    pwd
}
bash_prompt() {
  local NONE="\[\033[0m\]"    
  # regular colors
  local K="\[\033[0;30m\]"    # black
  local R="\[\033[0;31m\]"    # red
  local G="\[\033[0;32m\]"    # green
  local Y="\[\033[0;33m\]"    # yellow
  local B="\[\033[0;34m\]"    # blue
  local M="\[\033[0;35m\]"    # magenta
  local C="\[\033[0;36m\]"    # cyan
  local W="\[\033[0;37m\]"    # white
  local UC=$W                 
  [ $UID -eq "0" ] && UC=$R   
  PS1="${W}"
  USERHOST="$USER@$HOSTNAME"
  CNT=$(echo $USERHOST | wc -m)
  CNT=`expr 67 - $CNT`
  SPACES=$(printf "%${CNT}s" | tr " " "-")
  PS1="$PS1\n${W}+ $C$USER@$HOSTNAME$W $SPACES $Y\t$W +"
  PS1="$PS1\n${W}| $G\$(__cur_dir)$NONE"
  PS1="$PS1\n$NONE\\$ "
}
bash_prompt
unset bash_prompt

alias magerun="magerun --ansi"
' >> /etc/bashrc
