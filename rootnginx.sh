#!/bin/bash

fn_init() {

   read -p "Enter domain or subdomain: " doamin
   nginx_conf_name=./config/$doamin.conf

   echo "server {" > $nginx_conf_name
   echo "   listen 80;" >> $nginx_conf_name
   echo "   server_name $DOMAIN;" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "   location / {" >> $nginx_conf_name
   echo "      root /usr/share/nginx;" >> $nginx_conf_name
   echo "      index index.html;" >> $nginx_conf_name
   echo "   }" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "   location ~ /.well-known/acme-challenge/ {" >> $nginx_conf_name
   echo "      root /var/www/certbot;" >> $nginx_conf_name
   echo "   }" >> $nginx_conf_name
   echo "}" >> $nginx_conf_name
}

fn_ssl() {
   COMPOSE_YML=compose.yml

   cd ssl

   read -p "Enter domain or subdomain: " doamin
   read -p "Enter your email: " email

   echo "services:" > $COMPOSE_YML
   echo "  certbot:" >> $COMPOSE_YML
   echo "    image: certbot/certbot:latest" >> $COMPOSE_YML
   echo "    container_name: certbot" >> $COMPOSE_YML
   echo "    volumes:" >> $COMPOSE_YML
   echo "      - ./www:/var/www/certbot" >> $COMPOSE_YML
   echo "      - ./conf:/etc/letsencrypt" >> $COMPOSE_YML
   echo "    command: |" >> $COMPOSE_YML
   echo "      certonly" >> $COMPOSE_YML
   echo "      --webroot -w /var/www/certbot" >> $COMPOSE_YML
   echo "      --force-renewal" >> $COMPOSE_YML
   echo "      --email $email" >> $COMPOSE_YML
   echo "      --agree-tos" >> $COMPOSE_YML
   echo "      -d $doamin" >> $COMPOSE_YML

   docker compose up
   rm -fr $COMPOSE_YML
}

fn_update() {
   read -p "Enter your email: " email
   echo "feat update"
}

fn_help() {
   echo "Usage:  sh rootnginx.sh [OPTIONS]"
   echo ""
   echo "Options:"
   echo "   init     Initialize HTTP configuration"
   echo "   ssl      Initialize HTTPs configuration"
   echo "   update   Update SSL certificates"
}

# Main
if [ "$1" = "init" ]; then
   fn_init
elif [ "$1" = "ssl" ]; then
   fn_ssl
elif [ "$1" = "update" ]; then
   fn_update
else
   fn_help
fi