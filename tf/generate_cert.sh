#!/bin/bash

source /home/centos/utils/utils.sh

get_cert() {
    docker run --rm \
        -v /mnt/data/letsencrypt/etc:/etc/letsencrypt \
        -v /mnt/data/letsencrypt/www:/var/www \
        webdevops/certbot /usr/bin/certbot certonly \
        --non-interactive \
        --agree-tos \
        --webroot \
        -w /var/www \
        -m "stephan.a.hoffman@gmail.com" \
        -d "hh-app.$SC_ENV.hoffman-house.com,www.hoffman-house.com,hoffman-house.com"
        #--staging \
}

update_cert() {
    docker run --rm \
        -v /mnt/data/letsencrypt/etc:/etc/letsencrypt \
        -v /mnt/data/letsencrypt/www:/var/www \
        webdevops/certbot /usr/bin/certbot renew --non-interactive
       # webdevops/certbot /usr/bin/certbot renew --staging --non-interactive
}
if [ ! -e "/mnt/data/letsencrypt/etc/live/hh-app.$SC_ENV.hoffman-house.com/privkey.pem" ]; then
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
check_run_cmd "docker exec sc-nginx nginx -s reload"
