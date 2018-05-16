#!/bin/bash
source /home/centos/utils/utils.sh

TMP_DIR=/tmp/sc
mkdir -p $TMP_DIR

check_run_cmd "setenforce 0"
check_run_cmd "growpart /dev/xvda 2"
check_run_cmd "lvextend -l +100%FREE /dev/atomicos/root"
check_run_cmd "xfs_growfs  /"
check_run_cmd "sudo rm -rf $TMP_DIR/mysql_data && mkdir -p $TMP_DIR/mysql_data"

docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "TMP_DIR=$TMP_DIR" -v "/tmp/sc:/tmp/sc" mesosphere/aws-cli s3 cp s3://$SC_AWS_S3_BUCKET/docker/sc-mysql-$SC_ENV.tar $TMP_DIR
docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "TMP_DIR=$TMP_DIR" -v "/tmp/sc:/tmp/sc" mesosphere/aws-cli s3 cp s3://$SC_AWS_S3_BUCKET/docker/sc-smtp-$SC_ENV.tar $TMP_DIR
docker run --rm -t  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -e "AWS_DEFAULT_REGION=$SC_AWS_REGION" -e "SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET" -e "SC_ENV=$SC_ENV" -e "TMP_DIR=$TMP_DIR" -v "/tmp/sc:/tmp/sc" mesosphere/aws-cli s3 cp s3://$SC_AWS_S3_BUCKET/docker/sc-app-$SC_ENV.tar $TMP_DIR

check_run_cmd "docker load -i $TMP_DIR/sc-mysql-$SC_ENV.tar"
check_run_cmd "docker load -i $TMP_DIR/sc-app-$SC_ENV.tar"
check_run_cmd "docker load -i $TMP_DIR/sc-smtp-$SC_ENV.tar"

docker-compose -f /home/centos/squirrel/docker-compose.yml up -d 
#rm -rf /tmp/squirrel
