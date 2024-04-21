#!/bin/bash

CONFIG_FILE_NAME=
DOMAIN=$1
COMPOSE_YML=compose.yml

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

mk_certbot_docker_compose() {
   cd ssl
   echo "services:" > $COMPOSE_YML
   echo "  certbot:" >> $COMPOSE_YML
   echo "    image: certbot/certbot:latest" >> $COMPOSE_YML
   echo "    container_name: certbot" >> $COMPOSE_YML
   echo "    volumes:" >> $COMPOSE_YML
   echo "      - ../html/$DOMAIN/.well-known/acme-challenge:/var/www/certbot" >> $COMPOSE_YML
   echo "      - ./conf:/etc/letsencrypt" >> $COMPOSE_YML
   echo "    command: |" >> $COMPOSE_YML
   echo "      certonly" >> $COMPOSE_YML
   echo "      --webroot -w /var/www/certbot" >> $COMPOSE_YML
   echo "      --force-renewal" >> $COMPOSE_YML
   echo "      --email yasithanadeeshan@gmail.com" >> $COMPOSE_YML
   echo "      --agree-tos" >> $COMPOSE_YML
   echo "      -d $DOMAIN" >> $COMPOSE_YML
}

CONFIG_FILE_NAME=./config/$DOMAIN.conf
# mk_nginx_basic_setup
mk_certbot_docker_compose
