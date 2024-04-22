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
