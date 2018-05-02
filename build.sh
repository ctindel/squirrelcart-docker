#!/bin/bash

SC_VER=squirrelcart-pro-v3.0.1
SC_TARBALL=$SC_VER.tar.gz
SERVER_ROOT=/project
tmp_dir=/tmp/squirrel
mkdir -p $tmp_dir

docker rm -f squirrel
docker rmi -f ctindel/squirrelcart:prod 
docker rmi -f ctindel/squirrelcart-mysql:prod 
docker-compose build mysql
docker-compose build squirrel
docker-compose up -d
aws s3 cp s3://ctindel-squirrel/$SC_TARBALL $tmp_dir
docker exec squirrel mkdir -p $tmp_dir
docker cp $tmp_dir/$SC_TARBALL squirrel:$tmp_dir
docker cp install.sh squirrel:$tmp_dir
docker exec squirrel bash $tmp_dir/install.sh
