#!/bin/bash
source /home/centos/utils/utils.sh

TMP_DIR=/tmp/sc
DB=squirrelcart
TEST_TABLE=Products
mkdir -p $TMP_DIR

check_run_cmd "setenforce 0"
check_run_cmd "bash /home/centos/squirrel/setup_storage.sh"

docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "TMP_DIR=$TMP_DIR" -v "/tmp/sc:/tmp/sc" mesosphere/aws-cli s3 cp s3://$SC_AWS_S3_BUCKET/docker/sc-mysql-$SC_ENV.tar $TMP_DIR
docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "TMP_DIR=$TMP_DIR" -v "/tmp/sc:/tmp/sc" mesosphere/aws-cli s3 cp s3://$SC_AWS_S3_BUCKET/docker/sc-smtp-$SC_ENV.tar $TMP_DIR
docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "TMP_DIR=$TMP_DIR" -v "/tmp/sc:/tmp/sc" mesosphere/aws-cli s3 cp s3://$SC_AWS_S3_BUCKET/docker/sc-app-$SC_ENV.tar $TMP_DIR

check_run_cmd "docker load -i $TMP_DIR/sc-mysql-$SC_ENV.tar"
check_run_cmd "docker load -i $TMP_DIR/sc-app-$SC_ENV.tar"
check_run_cmd "docker load -i $TMP_DIR/sc-smtp-$SC_ENV.tar"

docker-compose -f /home/centos/squirrel/docker-compose.yml up -d 

check_run_cmd "docker exec sc-app bash $TMP_DIR/src/wait-for-mysql.sh"
table_exists=$(docker exec -it sc-app mysql -h mysql -u squirrelcart -psquirrelcart -N -s -e "select count(*) from information_schema.tables where table_schema='${DB}' and table_name='${TEST_TABLE}'")
table_exists=$(echo $table_exists | perl -pe 's/[^\w.-]+//g')
if [ $table_exists -eq 1 ]; then
    echo "Database is already loaded!"
else
    latest_backup=$(docker run --rm -t $(tty &>/dev/null && echo "-i") -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v "$(pwd):/project" mesosphere/aws-cli s3 ls s3://$SC_AWS_S3_BUCKET/backup/ | grep PRE | awk '{print $2}' | sort | sed -e 's#/##g')
    latest_backup=$(echo $latest_backup | perl -pe 's/[^\w.-]+//g')
    echo "Database is not loaded, will restore from latest backup $latest_backup"
    docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "TMP_DIR=$TMP_DIR" -e "latest_backup=$latest_backup" -v "/tmp/sc:/tmp/sc" mesosphere/aws-cli s3 cp s3://$SC_AWS_S3_BUCKET/backup/$latest_backup/$latest_backup-squirrelcart-hh.tar.gz $TMP_DIR/squirrelcart-hh.tar.gz
    docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "TMP_DIR=$TMP_DIR" -e "latest_backup=$latest_backup" -v "/tmp/sc:/tmp/sc" mesosphere/aws-cli s3 cp s3://$SC_AWS_S3_BUCKET/backup/$latest_backup/$latest_backup-squirrelcart-hh.sql.gz $TMP_DIR/squirrelcart-hh.sql.gz
    check_run_cmd "docker cp $TMP_DIR/squirrelcart-hh.sql.gz sc-app:$TMP_DIR"
    check_run_cmd "docker cp $TMP_DIR/squirrelcart-hh.tar.gz sc-app:$TMP_DIR"
    check_run_cmd "docker exec sc-app bash $TMP_DIR/src/install.sh"
fi

#rm -rf $TMP_DIR
