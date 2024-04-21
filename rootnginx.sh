#!/bin/bash

CONFIG_FILE_NAME=
DOMAIN=$1

mk_nginx_basic_setup() {
   echo "server {" > $CONFIG_FILE_NAME
   echo "   listen 80;" >> $CONFIG_FILE_NAME
   echo "   server_name $DOMAIN;" >> $CONFIG_FILE_NAME
   echo "" >> $CONFIG_FILE_NAME
   echo "   location / {" >> $CONFIG_FILE_NAME
   echo "      root /usr/share/nginx/$DOMAIN;" >> $CONFIG_FILE_NAME
   echo "      index index.html;" >> $CONFIG_FILE_NAME
   echo "   }" >> $CONFIG_FILE_NAME
   echo "}" >> $CONFIG_FILE_NAME

   # make public html
   PUBLIC_HTML_FOLDER=./html/$DOMAIN
   mkdir -p $PUBLIC_HTML_FOLDER/.well-known/acme-challenge

   cp ./nginx/index.html $PUBLIC_HTML_FOLDER
}

CONFIG_FILE_NAME=./config/$DOMAIN.conf
mk_nginx_basic_setup
