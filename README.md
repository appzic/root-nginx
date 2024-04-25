# Root Nginx

## Up Root Nginx
```bash
cd root-nginx
docker compose up -d
```

## Make HTTP connection
First, go to your DNS provider and create an `A Recode` for the domain or subdomain to point to the server's IP address.

Use following command to configure HTTP for the Nginx server:
```bash
sh rootnginx.sh init
```

After that, restat the Nginx server using following command:
```bash
docker compose restart
```

## Make HTTPs connection.
A few minutes later, go the [https://www.whatsmydns.net/](https://www.whatsmydns.net/) website and check wether DNS are successfully propegated or not.

If DNS successfully propergated, use following command to run certbot and configure HTTPS for Nginx server:
```bash
sh rootnginx.sh ssl
```

After that, restart the Nginx server using following command:
```bash
docker compose restart
```

## Update All SSL certificates.
```bash
sh rootnginx.sh update
```

## Nginx reverse proxy setup for HTTPS
edit the nginx config files `config/<site_url>.conf`

```conf
server {
   listen 80;
   server_name <site_url>;

   return 301 https://$host$request_uri;
}

server {
   listen 443 ssl http2;
   ssl_certificate /etc/letsencrypt/live/<site_url>/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/<site_url>/privkey.pem;
   server_name <site_url>;

   location / {
      proxy_pass http://internalnet:8080;
      proxy_set_header Host $http_host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
   }

}
```
