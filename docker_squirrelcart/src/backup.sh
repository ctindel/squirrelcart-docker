#!/bin/bash

SERVER_ROOT=/project
PROJECT_ROOT=$SERVER_ROOT/squirrelcart-hh
TMP_DIR=/tmp/sc
BACKUP_DIR=$TMP_DIR/backup

rm -rf $BACKUP_DIR && mkdir -p $BACKUP_DIR || exit 1
mysqldump -h mysql -u squirrelcart -psquirrelcart --databases squirrelcart > $BACKUP_DIR/squirrelcart-hh.sql || exit 1
gzip -c $BACKUP_DIR/squirrelcart-hh.sql > $BACKUP_DIR/squirrelcart-hh.sql.gz || exit 1

cp -a $PROJECT_ROOT $BACKUP_DIR || exit 1
chown -R root:root $BACKUP_DIR || exit 1
cd $BACKUP_DIR; tar zcpvf squirrelcart-hh.tar.gz squirrelcart-hh || exit 1

#echo "Press [CTRL+C] to stop.."
#while true
#do
#    sleep 1
#done
