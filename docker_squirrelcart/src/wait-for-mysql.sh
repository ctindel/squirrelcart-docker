#!/bin/bash

MYSQL_HOST=mysql
MYSQL_PORT=3306

# We need to wait for the mysql, es, and kibana containers to be up and running
while ! nc -z $MYSQL_HOST $MYSQL_PORT; do
  sleep 1
done
