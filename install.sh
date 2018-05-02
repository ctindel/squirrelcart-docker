#!/bin/bash

SC_VER=squirrelcart-pro-v3.0.1
SC_TARBALL=$SC_VER.tar.gz
SERVER_ROOT=/project
tmp_dir=/tmp/squirrel

mkdir -p $SERVER_ROOT
tar zxpvf $tmp_dir/$SC_TARBALL -C $tmp_dir
mv $tmp_dir/$SC_VER/* $SERVER_ROOT

#https://www.squirrelcart.com/help/3.2.0/Setting%20File%20Permissions.html
find $SERVER_ROOT/sc_images -type d | xargs chmod 777
chmod 777 $SERVER_ROOT/squirrelcart/sc_data
chmod 777 $SERVER_ROOT/squirrelcart/config.php
chown -R www-data:www-data $SERVER_ROOT/*
