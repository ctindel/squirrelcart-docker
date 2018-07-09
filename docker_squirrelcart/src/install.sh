#!/bin/bash

SERVER_ROOT=/project
PROJECT_ROOT=$SERVER_ROOT/squirrelcart-hh
TMP_DIR=/tmp/sc

rm -rf $PROJECT_ROOT && mkdir -p $PROJECT_ROOT

tar zxpvf $TMP_DIR/squirrelcart-hh.tar.gz -C $SERVER_ROOT
cp $TMP_DIR/src/config.php $PROJECT_ROOT/squirrelcart/config.php
gunzip -c $TMP_DIR/squirrelcart-hh.sql.gz > $TMP_DIR/squirrelcart-hh.sql
mysqladmin -f -h mysql -usquirrelcart -psquirrelcart drop squirrelcart
mysql -h mysql -u root -proot -e "create database squirrelcart; GRANT ALL PRIVILEGES ON squirrelcart.* TO squirrelcart IDENTIFIED BY 'squirrelcart'"
mysql -h mysql -usquirrelcart -psquirrelcart squirrelcart < $TMP_DIR/squirrelcart-hh.sql
rm -f $TMP_DIR/squirrelcart-hh.sql

#echo "Press [CTRL+C] to stop.."
#while true
#do
#    sleep 1
#done

# apache runs as the www-data user and we need to set some variables accordingly
cat << EOF > /etc/ssmtp/ssmtp.conf
root=postmaster
mailhub=sc-smtp
hostname=hoffman-house.com
FromLineOverride=YES
EOF

echo "www-data:sales@hoffman-house.com" >> /etc/ssmtp/revaliases
