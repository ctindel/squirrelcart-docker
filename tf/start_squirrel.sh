#!/bin/bash
source /home/centos/utils/utils.sh

TMP_DIR=/tmp/sc
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
#rm -rf /tmp/squirrel
