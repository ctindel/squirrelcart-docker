#!/bin/bash
source /home/centos/utils/utils.sh

export verbose=true
TMP_DIR=/tmp/sc
BACKUP_DIR=$TMP_DIR/backup
DB=squirrelcart
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

check_run_cmd "setenforce 0"
check_run_cmd "rm -rf $BACKUP_DIR && mkdir -p $BACKUP_DIR"

bash /home/centos/squirrel/generate_cert.sh

# Device Mapper Bug will fill up the available space in the docker pool 
#  as shown by docker info
# https://stackoverflow.com/questions/27853571/why-is-docker-image-eating-up-my-disk-space-that-is-not-used-by-docker
check_run_cmd "docker system prune -f"
check_run_cmd "docker image prune -f"
check_run_cmd "docker volume prune -f"
check_run_cmd "docker container prune -f"
check_run_cmd "docker ps -qa | xargs docker inspect --format='{{ .State.Pid }}' | xargs -IZ fstrim /proc/Z/root/"

check_run_cmd "docker exec sc-app bash $TMP_DIR/src/backup.sh"
check_run_cmd "docker cp sc-app:$BACKUP_DIR/squirrelcart-hh.sql.gz $BACKUP_DIR/$TIMESTAMP-squirrelcart-hh.sql.gz"
check_run_cmd "docker cp sc-app:$BACKUP_DIR/squirrelcart-hh.tar.gz $BACKUP_DIR/$TIMESTAMP-squirrelcart-hh.tar.gz"

docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "BACKUP_DIR=$BACKUP_DIR" -v "/tmp/sc/backup:/tmp/sc/backup" mesosphere/aws-cli s3 cp $BACKUP_DIR/$TIMESTAMP-squirrelcart-hh.tar.gz s3://$SC_AWS_S3_BUCKET/backup/${SC_ENV}/$TIMESTAMP/$TIMESTAMP-squirrelcart-hh.tar.gz

docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "BACKUP_DIR=$BACKUP_DIR" -v "/tmp/sc/backup:/tmp/sc/backup" mesosphere/aws-cli s3 cp $BACKUP_DIR/$TIMESTAMP-squirrelcart-hh.sql.gz s3://$SC_AWS_S3_BUCKET/backup/${SC_ENV}/$TIMESTAMP/$TIMESTAMP-squirrelcart-hh.sql.gz
#rm -rf $BACKUP_DIR
