

 # Docker
 ## 1. Common Words
 * Docker's words is written at [Glossary](https://docs.docker.com/reference/glossary/)

 ## 2. Build Errors References
 If your container is stopped, you check this site: [Build checks](https://docs.docker.com/reference/build-checks/)
 This page solve some your problem when you build container and run.(maybe)

 ## Docker Engine Manual
 You can learn Docker's behavior and infra.
 It's important for engineer.
 You can see [Docker Engine](https://docs.docker.com/engine/).
 It includes License, Network, Storage, Logs, Configure the daemon, Rootless mode, and so on.

 # Advanced Docker
 You don't need to learn this page for your building general containers.

 ## Build Container By Program #SDK #Docker #Docker_Engine_API
 * You can find this page [Docker Engine API](https://docs.docker.com/reference/api/engine/)

 ## Docker's volume driver_opt lists
 * [mount(8)](https://man7.org/linux/man-pages/man8/mount.8.html)

# Mariadb
 ## Create User Command
 ```
 CREATE USER "(username)"@"(hostname)" IDENTIFIED BY (password);
 ```
 > You must replace "username", "hostname" and "password" with yourself.

 ## ?. Connect mariadb from external host
 ```
 mysql --user=wordpress -password=password wordpress -h localhost
 ```

 ## Maridbd Options
 * [mariadbd-options (server option group)](https://mariadb.com/kb/en/mariadbd-options/)
 * [configuring-mariadb-with-option-files](https://mariadb.com/kb/en/configuring-mariadb-with-option-files/)
 * [account-management-sql-commands](https://mariadb.com/kb/en/account-management-sql-commands/)
 * [mariadb client options](https://mariadb.com/kb/en/mariadb-command-line-client/)

 ## [SQL statement](https://mariadb.com/kb/en/sql-statements/)
 * [create user](https://mariadb.com/kb/en/create-user/)
 * [grant](https://mariadb.com/kb/en/grant/)
 * [flush](https://mariadb.com/kb/en/flush/)
 * [create database](https://mariadb.com/kb/en/create-database/)

 ## Authenticate plugin
 * [mysql_native_password](https://mariadb.com/kb/en/authentication-plugin-mysql_native_password/) Not recommended
 * [ed25519](https://mariadb.com/kb/en/authentication-plugin-ed25519/) recommended

 # Wordpress (php-fpm)

 ## download wordpress path
 * [releases](https://ja.wordpress.org/download/releases/)
 * wordpress files: https://ja.wordpress.org/wordpress-6.8.1-ja.tar.gz
 * [PHPの互換性](https://ja.wordpress.org/team/handbook/core/references/php-compatibility-and-wordpress-versions/)

 ## connect command
 ```
 apt-get install -y libfcgi
 ```
 ```
 SCRIPT_FILENAME=/srv/wordpress/index.php \
 REQUEST_METHOD=GET \
	cgi-fcgi -bind -connect wordpress:9000
 ```

 # Vagrant
 ```
 cd ubuntu2004
 vagrant init ubuntu-20.04
 vagrant up
 vagrant ssh
 ```
 > default settings -> user: vagrant pass: vagrant

 ## install packages
 I should remove this section with overwriting the Vagrantfile.

 ### install docker
 ```sh
 sudo curl -fsSL https://get.docker.com -o get-docker.sh
 sudo sh ./get-docker.sh
 ```

 ### update docker with rootless mode
 ```sh
 sudo sh -eux <<EOF
 # Install newuidmap & newgidmap binaries
 apt-get install -y uidmap
 EOF
 dockerd-rootless-setuptool.sh install
 ```

 ### check installed
 ```sh
 docker run -it --rm alpine
 ```

 ### install Make
 ```sh
 sudo apt-get install -y make
 ```

 # Virtual Box
 ## ターミナルが起動しない時
 * [ターミナルが起動しない時](https://qiita.com/towamz/items/2052f08e9e1af4068a56)
