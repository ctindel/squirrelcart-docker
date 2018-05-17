#!/bin/bash

source /home/centos/utils/utils.sh

get_cert() {
    docker run --rm \
        -v /mnt/data/letsencrypt/etc:/etc/letsencrypt \
        -v /mnt/data/letsencrypt/www:/var/www \
        ekho/certbot certonly \
        --agree-tos \
        --webroot \
        --staging \
        -w /var/www \
        -m "chad@tindel.net" \
        -d ctindel-squirrel.${SC_ENV}.sa.elastic.co
}

update_cert() {
    docker run --rm \
        -v /mnt/data/letsencrypt/etc:/etc/letsencrypt \
        -v /mnt/data/letsencrypt/www:/var/www \
        ekho/certbot renew --staging
}

if [ ! -e "/mnt/data/letsencrypt/etc/live/ctindel-squirrel.prod.sa.elastic.co/privkey.pem" ]; then
    echo "Getting certificates..."
    get_cert
    check_run_cmd "cp -f /home/centos/squirrel/nginx.https.conf /home/centos/squirrel/nginx/"
else
    echo "Updating certificates..."
    update_cert
fi

docker exec sc-nginx nginx -s reload
