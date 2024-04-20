#!/bin/bash

CONFIG_FILE_NAME=
DOMAIN=$1

mk_nginx_basic_conf() {
   echo "server {" > $CONFIG_FILE_NAME
   echo "   listen 80;" >> $CONFIG_FILE_NAME
   echo "   server_name $DOMAIN;" >> $CONFIG_FILE_NAME
   echo "}" >> $CONFIG_FILE_NAME
}

CONFIG_FILE_NAME=./config/$DOMAIN.conf
mk_nginx_basic_conf