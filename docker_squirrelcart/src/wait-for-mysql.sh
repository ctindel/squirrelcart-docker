#!/bin/bash

MYSQL_HOST=mysql
MYSQL_PORT=3306

# We need to wait for the mysql, es, and kibana containers to be up and running
while ! nc -z $MYSQL_HOST $MYSQL_PORT; do
  sleep 1
done

# Wait until we can successfully execute a query
until mysql -h $MYSQL_HOST -u squirrelcart -psquirrelcart -e "show processlist" > /dev/null; do
    echo Waiting for Mysql....
    sleep 1
done
