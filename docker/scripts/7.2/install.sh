#!/bin/bash

DATE=$(date +'%Y-%m-%d')
TMP_INSTALLED="/tmp/scripts-installed"
PROJECT_ROOT="/var/www/html"
SUPERVCONF="/etc/supervisord.conf"
LOGSDIR="/etc/supervisor/logs"
SSH_PATH="/root/.ssh/id_rsa"
REDISPASS="9$>v6Zvv@nuY"

echo -e ">>> \e[96m[Hello world!]\e[39m > \e[33m[Let's go...]\e[39m";
cat /etc/os-release
echo "____________________________________________________________________";

if [[ -f "${TMP_INSTALLED}" ]]
then
  echo -e ">>> \e[32m[Not running install scripts]\e[39m > [${TMP_INSTALLED} exists]";
else
  echo -e ">>> \e[32m[Running install scripts]\e[39m > \e[33m[In progress...]\e[39m";
  touch "${TMP_INSTALLED}";

  # vim /etc/redis.conf -> requirepass <pass> (line ~500)
  apt-get update > /dev/null 2>&1
  apt-get install sudo > /dev/null 2>&1

  apt-get -y install --reinstall systemd > /dev/null 2>&1

  apt-get -y install libpcre3 libgcc libstdc++ libx11 glib libxrender libxext libintl libcrypto1.0 libssl1.0 > /dev/null 2>&1
  apt-get -y install ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family libxml2 libxml++2.6-dev > /dev/null 2>&1

  apt-get -y install --yes --allow-unauthenticated vim nano net-tools wget > /dev/null 2>&1
fi

## apt-cache search php7-*
## php -i | grep "Loaded Configuration File"

echo -e ">>> \e[32m[Projects]\e[39m > \e[33m[Check]\e[39m";
cd /var/www/html && ls -ldm -- */
cd ~ || echo "Cannot cd to root"
apt-get update > /dev/null 2>&1
echo "____________________________________________________________________";

echo -e ">>> \e[32m[PHP]\e[39m > \e[33m[In progress...]\e[39m";
# 7.0 not available
# 7.1 cli and fpm not found
# apt-get -y install php7.1-cli php7.1-fpm

# 7.2-cli already there
apt-get -y install php7.2-fpm > /dev/null 2>&1
service php7.2-fpm start
# reload and restart now nginx
ls -m /etc/php
echo "____________________________________________________________________";

echo -e ">>> \e[32m[nginx]\e[39m > \e[33m[In progress...]\e[39m";
apt -y install --yes --allow-unauthenticated --fix-broken install > /dev/null 2>&1

apt-get -y install nginx > /dev/null 2>&1

#/etc/nginx/snippets/fastcgi-php.conf.dpkg-new
#/etc/nginx/snippets/snakeoil.conf.dpkg-new

# otherwise apps configs will make nginx fail
FAST_FILE=/etc/nginx/snippets/fastcgi-php.conf
echo "${FAST_FILE} ..."

if [ -f "$FAST_FILE" ]; then
    echo "${FAST_FILE} exists."
else
	  FAST_FILE_NEW=/etc/nginx/snippets/fastcgi-php.conf.dpkg-new
    if [ -f "$FAST_FILE_NEW" ]; then
		  cp /etc/nginx/snippets/fastcgi-php.conf.dpkg-new /etc/nginx/snippets/fastcgi-php.conf
    else
      echo "No ${FAST_FILE_NEW} file."
    fi
fi

SNAKE_FILE=/etc/nginx/snippets/snakeoil.conf
echo "${SNAKE_FILE} ..."

if [ -f "$SNAKE_FILE" ]; then
    echo "${SNAKE_FILE} exists."
else
	  SNAKE_FILE_NEW=/etc/nginx/snippets/snakeoil.dpkg-new
    if [ -f "$SNAKE_FILE_NEW" ]; then
		  cp /etc/nginx/snippets/snakeoil.conf.dpkg-new /etc/nginx/snippets/snakeoil.conf
		else
      echo "No ${SNAKE_FILE_NEW} file."
    fi
fi

# reload and start
service nginx reload
service nginx start

echo "____________________________________________________________________";

echo -e ">>> \e[32m[nginx]\e[39m > \e[33m[TEST]\e[39m";
nginx -v
nginx -t # to dump all: nginx -T

service nginx configtest
#nginx -t

apt-get -y install build-essential > /dev/null 2>&1
apt-get -y install libz-dev libssl-dev libcurl4-openssl-dev libexpat-dev gettext > /dev/null 2>&1
apt-get -y install autoconf > /dev/null 2>&1

#tail -f /var/log/nginx/access.log
#tail -f /var/log/nginx/error.log -  fastcgi-php.conf.dpkg-new?
#netstat -tupln | grep 443

tail -10 /var/log/nginx/error.log
echo "____________________________________________________________________";

echo -e ">>> \e[32m[Composer]\e[39m > \e[33m[In progress...]\e[39m";
apt-get -y install composer > /dev/null 2>&1
composer --version
echo "____________________________________________________________________";

echo -e ">>> \e[32m[Modules]\e[39m > \e[33m[In progress...]\e[39m";
apt-get -y install --yes --allow-unauthenticated vim nano net-tools \
	php-bcmath php-curl php-dom php-gd  php-mbstring mcrypt \
	php-mysqli php-mysql php7.2-mysql \
	php-xml php7.2-xml php-soap php7.2-soap php-zip php7.2-zip > /dev/null 2>&1

php -m
echo "____________________________________________________________________";

echo -e ">>> \e[32m[Other packages]\e[39m > \e[33m[In progress...]\e[39m";
apt-get -y install redis php-igbinary php-imagick php-intl > /dev/null 2>&1

#redis -v
echo "____________________________________________________________________";

echo -e ">>> \e[32m[Services]\e[39m > \e[33m[STATUS]\e[39m";
service --status-all
echo "____________________________________________________________________";

#git for ubuntu 14.04+
echo -e ">>> \e[32m[GIT]\e[39m > \e[33m[In progress...]\e[39m";

# done above - apt-get -y install software-properties-common # for 13.x - python-software-properties

apt-add-repository ppa:git-core/ppa > /dev/null 2>&1
apt-get update > /dev/null 2>&1
apt-get -y install git > /dev/null 2>&1 #should install latest
echo "____________________________________________________________________";

echo -e ">>> \e[32m[nginx]\e[39m > \e[33m[RESTART]\e[39m";
service nginx restart
service nginx status
echo "____________________________________________________________________";

echo -e ">>> \e[32m[XDebug]\e[39m > \e[33m[In progress...]\e[39m";
apt-get install -y php-xdebug > /dev/null 2>&1
echo "____________________________________________________________________";

echo -e ">>> \e[32m[PHPUnit]\e[39m > \e[33m[In progress...]\e[39m";
cd /

# muted
sudo wget -O phpunit-6.5 https://phar.phpunit.de/phpunit-6.5.phar > /dev/null 2>&1
#sudo wget -O phpunit-6.5 https://phar.phpunit.de/phpunit-6.5.phar

PHPUNIT_DIR=phpunit-6.5
if [ -f "$PHPUNIT_DIR" ]; then
  sudo chmod +x phpunit-6.5
  sudo mv phpunit-6.5 /usr/local/bin/phpunit
else
    echo "${PHPUNIT_DIR} does not exist. Cannot move to /usr/local/bin/phpunit."
fi

#sudo chmod +x phpunit-6.5.phar
#sudo mv phpunit-6.5.phar /usr/local/bin/phpunit
phpunit --version

echo "____________________________________________________________________";

echo -e ">>> \e[32m[Supervisor]\e[39m > \e[33m[In progress...]\e[39m";
apt-get install -y supervisor > /dev/null 2>&1
echo "____________________________________________________________________";

echo -e ">>> \e[32m[Redis]\e[39m > \e[33m[In progress...]\e[39m";
adduser redis
apt-get install -y redis-server > /dev/null 2>&1

echo "____________________________________________________________________";

echo -e ">>> \e[32m[...]\e[39m > \e[33m[Check]\e[39m";
echo "* PHP >>>"
php --version
echo "* Redis >>>"
redis-server -v
redis-cli -v
echo "____________________________________________________________________";

echo -e ">>> \e[32m[Supervisor]\e[39m > \e[33m[In progress...]\e[39m";
service supervisor status
echo "____________________________________________________________________";

echo -e ">>> \e[32m[GoIBAN]\e[39m > \e[33m[In progress...]\e[39m";
# /usr/local/bin/goiban.service
sudo cp /etc/systemd/system/goiban_tmp.service /etc/systemd/system/goiban.service
sudo chmod 644 /etc/systemd/system/goiban.service
sudo cp /etc/systemd/system/goiban.service /usr/local/bin/
sudo mkdir /etc/goiban
sudo mkdir /etc/goiban/data
sudo mkdir /etc/goiban/static

GO_IBAN_DATA="${PROJECT_ROOT}/iban/goiban-service/data/"
if [ -f "${GO_IBAN_DATA}" ]; then
  cp -a "${PROJECT_ROOT}/iban/goiban-service/data/*" "/etc/goiban/data/"
else
    echo "${GO_IBAN_DATA} does not exist. Cannot move to /etc/goiban/data/"
fi

GO_IBAN_STATIC="${PROJECT_ROOT}/iban/goiban-service/static/"
if [ -f "${GO_IBAN_STATIC}" ]; then
  cp -a "${PROJECT_ROOT}/iban/goiban-service/static/*" "/etc/goiban/static/"
else
    echo "${GO_IBAN_STATIC} does not exist. Cannot move to /etc/goiban/static/"
fi

service dbus start ### if not, there will be Failed to connect to bus: No such file or directory
systemctl enable goiban.service
echo "____________________________________________________________________";

echo -e ">>> \e[32m[WkHtmlToPdf 0.12.5]\e[39m > \e[33m[In progress...]\e[39m";
apt-get -y install fontconfig libxrender1 libfontenc1 libxfont1 x11-common xfonts-encodings xfonts-utils xfonts-75dpi xfonts-base > /dev/null 2>&1

# muted
sudo wget -P Downloads https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.trusty_amd64.deb > /dev/null 2>&1
#sudo wget -P Downloads https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.trusty_amd64.deb

# shellcheck disable=SC2164
cd Downloads
sudo dpkg -i wkhtmltox_0.12.5-1.trusty_amd64.deb > /dev/null 2>&1

cd /usr/local/bin/ || echo "Cannot cd to /usr/local/bin/"

cp wkhtmltoimage /usr/bin/wkhtmltoimage
cp wkhtmltopdf /usr/bin/wkhtmltopdf

chmod 777 wkhtmltopdf
chmod 777 wkhtmltoimage

cp /var/www/html/contracts/vendor/h4cc/wkhtmltoimage-amd64/bin/wkhtmltoimage-amd64 /usr/local/bin/
cp /var/www/html/contracts/vendor/h4cc/wkhtmltopdf-amd64/bin/wkhtmltopdf-amd64 /usr/local/bin/

chmod 777 wkhtmltopdf-amd64
chmod 777 wkhtmltoimage-amd64

cd ~ || echo "Cannot cd to root"
echo "____________________________________________________________________";

echo -e ">>> \e[32m[DIRECTORIES]\e[39m > \e[33m[Setting up...]\e[39m";

echo "* Logs directory ${LOGSDIR} >>>>"
if [[ ! -e "${LOGSDIR}" ]]; then
    mkdir -p "${LOGSDIR}"
	chmod 777 "${LOGSDIR}"
    echo "* Directory ${LOGSDIR} created :)"
elif [[ ! -d "${LOGSDIR}" ]]; then
    echo "* Directory ${LOGSDIR} already exists but is not a directory" 1>&2
else
    echo "* Directory ${LOGSDIR} exists :)"
fi

echo "* Supervisor config ${SUPERVCONF} >>>>"
if [ -f "${SUPERVCONF}" ]; then
    echo "* File ${SUPERVCONF} exist :)"
else
    echo "* File ${SUPERVCONF} does not exist. Creating!"
	mkdir -p /etc/supervisord/
	touch ${SUPERVCONF}
fi
echo "____________________________________________________________________";

echo -e ">>> \e[32m[SSH]\e[39m > \e[33m[Generating default key pair (${DATE})]\e[39m";
TS=$(date +'%T')
SSH_COPIED_PATH="${PROJECT_ROOT}/storage/container_id_rsa_7.2_${DATE}_${TS}"
#if already generated
if [ -f ${SSH_PATH} ]; then
    echo "${SSH_PATH} file exist.";
else
    # already copied file outside then remove
    if [ -f "${SSH_COPIED_PATH}.pub" ]; then
        rm "${SSH_COPIED_PATH}.pub";
    fi

    # generate
    echo "${SSH_PATH} will be created";

    ##ssh-keygen -y -t rsa -f "${SSH_PATH}" -q -P ""
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
    if [ -f "${SSH_PATH}.pub" ]; then
      cp "${SSH_PATH}.pub" "${SSH_COPIED_PATH}.pub";
      if [ -f "${SSH_COPIED_PATH}.pub" ]; then
        echo "${SSH_COPIED_PATH}.pub created!";
      else
        echo "${SSH_COPIED_PATH}.pub NOT created!";
      fi
    else
      echo "${SSH_PATH}.pub has not been generated. Run ssh-keygen manually!";
    fi
fi

echo "____________________________________________________________________";

echo -e ">>> \e[32m[KVK certs]\e[39m > \e[33m[Updating]\e[39m"
# https://developers.kvk.nl/guides
# sudo cp kvk-certs/*.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
curl https://ssltest.kvk.nl/
echo "____________________________________________________________________";

echo -e ">>> \e[32m[Service PHP]\e[39m > \e[33m[Restarted...]\e[39m"
service php7.2-fpm reload
service php7.2-fpm restart
echo "____________________________________________________________________";

echo -e ">>> \e[32m[Service Redis-server]\e[39m > \e[33m[Started...]\e[39m"
redis-server --daemonize yes

echo -e "redis-cli version >>>"
redis-cli -v
echo -e "Example use: 'redis-cli -h host.domain.com -p port -a pass'"
echo -e "Check: PUBSUB CHANNELS"
echo "____________________________________________________________________";

echo -e ">>> \e[33m[Reminder]\e[39m > \e[31m[Not installed...]\e[39m"
echo -e "Go to docker container and run by hand >>>"
echo -e "$> apt --fix-broken install -y"
echo -e "$> apt-get -y install libfontconfig1 libxrender1"
# otherwise not possible to generate PDF
#apt --fix-broken install -y
#apt-get -y install libfontconfig1 libxrender1
#or = apt install libfontconfig1 libxrender1

echo "____________________________________________________________________";

echo -e ">>> \e[32m[Redis added with password]\e[39m"
echo -e "Use e.g. >>>"
echo -e "$> AUTH ${REDISPASS}"

echo "____________________________________________________________________";

echo -e ">>> \e[32m[*.pub saved]\e[39m"
echo -e "Go to project [paydia-storage] on your local that maps >>> "
echo -e "${SSH_COPIED_PATH}.pub"

echo "____________________________________________________________________";

echo -e ">>> \e[32m[Install finished!]\e[39m > \e[96m[ENJOY!!!]\e[39m";

#Start serving (this also prevents the container from exiting) - in start.sh
if [ -f "${SUPERVCONF}" ]; then
	echo "* Executing supervisor with ${SUPERVCONF} config. Please wait..."
  exec /usr/bin/supervisord -n -c ${SUPERVCONF} > /dev/null 2>&1
else
	echo "* File ${SUPERVCONF} does not exist. Can't run!";
  pause
fi

echo -e ">>> \e[32m[Processes]\e[39m > \e[33m[Started...]\e[39m"
supervisorctl
echo "____________________________________________________________________";