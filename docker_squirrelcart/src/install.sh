#!/bin/bash

SC_VER=squirrelcart-pro-v3.0.1
SC_TARBALL=$SC_VER.tar.gz
SERVER_ROOT=/project
TMP_DIR=/tmp/sc

mkdir -p $SERVER_ROOT
tar zxpvf $TMP_DIR/$SC_TARBALL -C $TMP_DIR
mv $TMP_DIR/$SC_VER/* $SERVER_ROOT

#https://www.squirrelcart.com/help/3.2.0/Setting%20File%20Permissions.html
find $SERVER_ROOT/sc_images -type d | xargs chmod 777
chmod 777 $SERVER_ROOT/squirrelcart/sc_data
chmod 777 $SERVER_ROOT/squirrelcart/config.php

cp $TMP_DIR/src/config.php /project/squirrelcart
rm -rf /project/sc_install
chown -R www-data:www-data $SERVER_ROOT/*

gunzip -c $TMP_DIR/sc-initial-install.sql.gz > $TMP_DIR/sc-initial-install.sql
mysql -h mysql -u squirrelcart -psquirrelcart squirrelcart < $TMP_DIR/sc-initial-install.sql

#echo "Press [CTRL+C] to stop.."
#while true
#do
#    sleep 1
#done

