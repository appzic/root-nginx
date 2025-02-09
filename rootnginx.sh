#!/bin/bash

fn_init() {

   read -p "Enter domain or subdomain: " domain
   nginx_conf_name=./config/$domain.conf

   echo "server {" > $nginx_conf_name
   echo "   listen 80;" >> $nginx_conf_name
   echo "   server_name $domain;" >> $nginx_conf_name
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

   docker compose down
   docker compose up -d
}

fn_ssl() {
   compose_yml=compose.yml

   cd ssl

   read -p "Enter domain or subdomain: " domain
   read -p "Enter your email: " email

   echo "services:" > $compose_yml
   echo "  certbot:" >> $compose_yml
   echo "    image: certbot/certbot:latest" >> $compose_yml
   echo "    container_name: certbot" >> $compose_yml
   echo "    volumes:" >> $compose_yml
   echo "      - ./www:/var/www/certbot" >> $compose_yml
   echo "      - ./conf:/etc/letsencrypt" >> $compose_yml
   echo "    command: |" >> $compose_yml
   echo "      certonly" >> $compose_yml
   echo "      --webroot -w /var/www/certbot" >> $compose_yml
   echo "      --force-renewal" >> $compose_yml
   echo "      --email $email" >> $compose_yml
   echo "      --agree-tos" >> $compose_yml
   echo "      -d $domain" >> $compose_yml

   docker compose up
   rm -fr $compose_yml

   cd ..
   nginx_conf_name=./config/$domain.conf

   echo "server {" > $nginx_conf_name
   echo "   listen 80;" >> $nginx_conf_name
   echo "   server_name $domain;" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "   return 301 https://\$host\$request_uri;" >> $nginx_conf_name
   echo "}" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "server {" >> $nginx_conf_name
   echo "   listen 443 ssl http2;" >> $nginx_conf_name
   echo "   ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;" >> $nginx_conf_name
   echo "   ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;" >> $nginx_conf_name
   echo "   server_name $domain;" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "   location / {" >> $nginx_conf_name
   echo "      root /usr/share/nginx;" >> $nginx_conf_name
   echo "      index index.html;" >> $nginx_conf_name
   echo "   }" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "}" >> $nginx_conf_name

   docker compose down
   docker compose up -d
}

fn_update() {
   read -p "Enter your email: " email

   cd ./ssl
   files=../config/*.conf
   compose_yml=compose.yml

   echo "services:" > $compose_yml
   echo "  certbot:" >> $compose_yml
   echo "    image: certbot/certbot:latest" >> $compose_yml
   echo "    container_name: certbot" >> $compose_yml
   echo "    volumes:" >> $compose_yml
   echo "      - ./www:/var/www/certbot" >> $compose_yml
   echo "      - ./conf:/etc/letsencrypt" >> $compose_yml
   echo "    command: |" >> $compose_yml
   echo "      certonly" >> $compose_yml
   echo "      --webroot -w /var/www/certbot" >> $compose_yml
   echo "      --force-renewal" >> $compose_yml
   echo "      --email $email" >> $compose_yml
   echo "      --agree-tos" >> $compose_yml
   for file in $files; do
      domain=$(basename "${file}" .conf)
      echo "      -d $domain" >> "$compose_yml"
   done

   docker compose up
   rm -fr $compose_yml

   cd ..
   docker compose down
   docker compose up -d
}

fn_reverse_proxy() {

   read -p "Enter domain or subdomain: " domain
   read -p "Enter proxy address: " proxy

   nginx_conf_name=./config/$domain.conf

   echo "server {" > $nginx_conf_name
   echo "   listen 80;" >> $nginx_conf_name
   echo "   server_name $domain;" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "   return 301 https://\$host\$request_uri;" >> $nginx_conf_name
   echo "}" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "server {" >> $nginx_conf_name
   echo "   listen 443 ssl http2;" >> $nginx_conf_name
   echo "   ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;" >> $nginx_conf_name
   echo "   ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;" >> $nginx_conf_name
   echo "   server_name $domain;" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "   location / {" >> $nginx_conf_name
   echo "      proxy_pass $proxy;" >> $nginx_conf_name
   echo "      proxy_set_header Host \$http_host;" >> $nginx_conf_name
   echo "      proxy_set_header X-Real-IP \$remote_addr;" >> $nginx_conf_name
   echo "      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> $nginx_conf_name
   echo "      proxy_set_header X-Forwarded-Proto \$scheme;" >> $nginx_conf_name
   echo "   }" >> $nginx_conf_name
   echo "" >> $nginx_conf_name
   echo "}" >> $nginx_conf_name

   docker compose down
   docker compose up -d
}

fn_help() {
   echo "Usage:  sh rootnginx.sh [OPTIONS]"
   echo ""
   echo "Options:"
   echo "   init     Initialize HTTP configuration"
   echo "   ssl      Initialize HTTPs configuration"
   echo "   rp       Configure HTTPs reverse proxy"
   echo "   update   Update SSL certificates"
}

# Main
if [ "$1" = "init" ]; then
   fn_init
elif [ "$1" = "ssl" ]; then
   fn_ssl
elif [ "$1" = "rp" ]; then
   fn_reverse_proxy
elif [ "$1" = "update" ]; then
   fn_update
else
   fn_help
fi