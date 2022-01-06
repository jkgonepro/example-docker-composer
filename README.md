# ubuntu-based docker configuration

[![State badge](https://img.shields.io/badge/Build-alpha-orange.svg)](...)
[![Version badge](https://img.shields.io/badge/Version-2.0-blue.svg)](...)
[![Last stable badge](https://img.shields.io/badge/Last_stable-1.6-green.svg)](...)
[![Licence badge](https://img.shields.io/badge/Licence-GPL-1f425f.svg)](...)

## Contains services
[![service_mariadb](https://img.shields.io/badge/10.200.0.3-service_mariadb-1f425f.svg)](#)
[![ports](https://img.shields.io/badge/3376-3306-lightgray.svg)](#)

[![service_mailcatcher](https://img.shields.io/badge/10.200.0.4-service_mailcatcher-blue.svg)](#)
[![port](https://img.shields.io/badge/1080-1080-lightgray.svg)](#)
[![port](https://img.shields.io/badge/1025-1025-lightgray.svg)](#)

[![service_phpmyadmin](https://img.shields.io/badge/10.200.0.5-service_phpmyadmin-orange.svg)](#)
[![port](https://img.shields.io/badge/8081-80-lightgray.svg)](#)

[![service_phpmyadmin](https://img.shields.io/badge/10.200.0.7-service_laravel_PHP7.0_16.04-red.svg)](#)
[![port](https://img.shields.io/badge/8088-80-lightgray.svg)](#)
[![php](https://img.shields.io/badge/PHP-7.0-1f425f.svg)](#)
[![php](https://img.shields.io/badge/Ubuntu-16.04-1f425f.svg)](#)

[![service_phpmyadmin](https://img.shields.io/badge/10.200.0.8-service_laravel_PHP7.2_18.04-red.svg)](#)
[![port](https://img.shields.io/badge/8089-80-lightgray.svg)](#)
[![php](https://img.shields.io/badge/PHP-7.2-1f425f.svg)](#)
[![php](https://img.shields.io/badge/Ubuntu-18.04-1f425f.svg)](#)

`default service on port 80`

[![service_phpmyadmin](https://img.shields.io/badge/10.200.0.6-service_laravel_PHP7.4_20.04-red.svg)](#)
[![port](https://img.shields.io/badge/80-80-lightgray.svg)](#)
[![php](https://img.shields.io/badge/PHP-7.4-1f425f.svg)](#)
[![php](https://img.shields.io/badge/Ubuntu-20.04-1f425f.svg)](#)

###### Please switch port to 80:80 on other container, and/or remove others if you dont want to use them from general .yml file
#### Current configuration will set container with PHP7.4 as main one. Names does not matter, you can rename containers as long as all depend on mysql container and main one is exposed to port 80.
#### If you want to access container in browser use port in dark gray badge. Light is port within a container.

Example PHPMyAdmin: `http://127.0.0.1:8081/`

Example MailCatcher: `http://127.0.0.1:1080/`

## How to run project with Docker
#### Installation for local dev (OSX)
* Install Docker CE for OSX (https://download.docker.com/mac/stable/Docker.dmg)
* Install docker-compose in your host machine (https://docs.docker.com/compose/install/)

#### Installation for local dev (Windows 10)
* Install Docker CE for Windows 10 (https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe)
* Install docker-compose in your host machine (https://docs.docker.com/docker-for-windows/install/)

#### Installation for local dev (Ubuntu)
* Install docker CE for ubuntu (https://docs.docker.com/install/linux/docker-ce/ubuntu/)
* Install docker-compose for ubuntu (https://docs.docker.com/compose/install/)
* In ubuntu you need to add your user to the docker group

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

#### Frontend configuration settings     
* Copy `.env` from `.env.example`
* Create a `.env.local` with the following
```dotenv
backend_domain='http://10.200.0.5:80'
backend_domain_proxy='localhost:3000/api'
secured_backend ='false'
laravel_echo_server_host='http://localhost'
```

And place it in ```/source``` folder in the front end.

#### Backend configuration settings
* Create `.env` file from `.env.example`
It should contains as follows assuming `xxxxxx` is the project e.g. `contracts`,`registrations`,`crm` etc.     

```dotenv  

APP_NAME=octa_xxxxxx
APP_ENV=dev
APP_KEY=<code_hete>
APP_DEBUG=true
APP_LOG_LEVEL=debug
APP_URL=xxxxxx.myshop.local

DB_CONNECTION=mysql
DB_HOST=10.200.0.3
DB_PORT=3306
DB_DATABASE=local_3
DB_USERNAME=homestead
DB_PASSWORD=secret

...
etc

```


You need to ask for db password and change `xxxxxx` depending on which project it is ***Do not forget any one of them***

* Xdebug is connecting to port `9002` of PHPStorm and not the default `9000` of the host machine so change your PHPStorm setting accordingly.
    (Port `9000` of the backend container is reserved for php-fpm)
    Keep in mind that `xdebug` is set up only of OSX (`xdebug.remote_host=docker.for.mac.localhost`), change this if you want to run the docker in linux

    If using browser's Xdebug widget, keep in mind to change IDE key to PhpStorm of `PHPSTORM`
    In `Settings -> Language & Frameworks -> PHP -> Servers` set like following:

```
Name: docker-laravel
Host: 0.0.0.0
Port: 9002
Debugger: Xdebug
Use path mappings: Yes
```

Example mapping:

```
File/Directory: <path_to_docker_content>/projects/admin
Absolute path on the server: /var/www/html/admin
```

```
File/Directory: <path_to_docker_content>/projects/shop
Absolute path on the server: /var/www/html/shop
```

If necessary or preferable check:

```
Break at first line in PHP scrips
```

### Start
#### Start all containers

```bash
docker-compose up  #if you want to also attach to the logs
```
All domains point to directories as defined in Docker's configuration.

#### Get into (laravel) container

```bash
docker exec -it service_laravel /bin/bash
```
Now you need to copy two things in order wizard to work:

```bash
cp /var/www/html/v2/contracts/vendor/h4cc/wkhtmltoimage-amd64/bin/wkhtmltoimage-amd64 /usr/local/bin/
```

```bash
cp /var/www/html/v2/contracts/vendor/h4cc/wkhtmltopdf-amd64/bin/wkhtmltopdf-amd64 /usr/local/bin/
```

Also changing permissions on both may be needed:

```bash
cd /usr/local/bin/
chmod 777 wkhtmltopdf-amd64
chmod 777 wkhtmltoimage-amd64
```

#### Get into (mysql) container

Use command:

```bash
docker exec -it service_mysql /bin/bash
```

Log into mysql and pick the db:

```bash
mysql -uroot -psecret
```

The should be already db ``local_3``:

```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| dumps              |
| local_3            |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.01 sec)
```

To make any changes thru command line, pick db by:

```
mysql> USE local_3;
```

### Workbench
```
Connection Method: Standard (TCP/IP)
Hostname: 127.0.0.1
Port: 3376
Username: root
Password: <you_know>

Default Schema: none or local_3
```

### env
##### mariadb - 3376:3306 <---
##### mysql - 3306:3306
```
DB_CONNECTION=mysql
DB_HOST=10.200.0.3
DB_PORT=3306
DB_DATABASE=local_3
DB_USERNAME=homestead
DB_PASSWORD=secret
```

### PhpStorm
#### Configuring Docker in PhpStorm
* In your Docker's general settings, please check:

```
Expose daemon on tcp://localhost:2375 without TLS
```

* Install Docker's extension in PhpStorm
* Add Docker config in ```Build, Execution, Deployment -> Docker```
Config should have same Engine API URL and correct path mappings.

Docker should now be visible in Tab - Services. You can easily "play" with it :)

#### Configuring MySQL in PhpStorm (from Docker's container)
 Go to DB settings and add MySQL db with settings like following:

```
Name: <whatever_you_like>
Comment: <whatever_you_like>
Host: 127.0.0.1
Port: 3306
User: homestead
Password: secret
Database local_3
URL: jdbc:mysql://127.0.0.1:3306/local_3
```

### Supervisor workers and subscribers -> PUBSUB CHANNELS
```
1) "message-queued"
2) "notification-pushed"
7) "payment-synced"
```

### Useful scripts
##### On MariaDB container:
In root directory

Go to MariaDB container (tab: `mariadb.bat`), then in root directory run `bash import_db.sh`
and provide data to import dump located in you local at `\storage\mariadb\dumps`

#### Apps mapping Win vs Ubuntu
`/var/www/html/x` -> `projects/x`
`*` - spot the difference, otherwise change your *.yml file
```
admin -> admin
shop -> shop
```


##### Supervisor latest (2021-06-09) configuration list from live
```
laravel-worker-notification-pushed
php-fpm
redis-server
redis-subscriber-messages
```

So `config.d` should therfore contain

```
1. laravel-worker-notification-pushed.conf
2. redis-server.conf
3. redis-subscriber-messages.conf
```

And every should contain `user=root` and have logs under
`/etc/supervisor/logs/supervisor.<name>.out.log`
and
`/etc/supervisor/logs/supervisor.<name>.err.log`
