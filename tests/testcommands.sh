#!/bin/bash

#
#
# wordpress service
#
#

# check is opened port wordpress php-fpm
apt-get install -y netcat-openbsd
apt-get install -y lsof
nc -vz wordpress 9000
lsof -i:9000

# get page
SCRIPT_FILENAME=/inde.php REQUEST_METHOD=GET cgi-fcgi -bind -connect wordpress:9000

# download wordpress files
curl -o https://ja.wordpress.org/latest-ja.zip
