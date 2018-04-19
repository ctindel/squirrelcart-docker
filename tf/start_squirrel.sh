#!/bin/bash
source /home/centos/utils/vars.sh

tmp_dir=/tmp/squirrel
mkdir -p $tmp_dir

docker-compose -f /home/centos/squirrel/docker-compose.yml up -d 
#rm -rf /tmp/squirrel
