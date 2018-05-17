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
else
    echo "Updating certificates..."
    update_cert
fi

# This will cover the case both where we just generated a cert, and also where we did
#  clean launch but where the cert was already generated on the volume previously (as
#  in when terminating the instance manually)
check_run_cmd "cp -f /home/centos/squirrel/nginx.https.conf /home/centos/squirrel/nginx/"
docker exec sc-nginx nginx -s reload
