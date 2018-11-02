#!/bin/bash

# Add your backup dir location, password, mysql location and mysqldump location
DATE=$(date +%d-%m-%Y)
TIME=$(date +"%r")
BACKUP_DIR="/home/backup"
MYSQL_USER="root"
MYSQL_PASSWORD="drRdhkr46"
MYSQLADMIN=/usr/bin/mysqladmin

# To generate name of mysql-bin file before incremental backup
MYSQLBIN_OLD=`ls -lrth /home/mysql | grep mysql-bin.* | awk '{ print $9 }' | egrep -v "mysql-bin.index" | tail -n 1`
echo "The mysql-bin file before incremental backup on $DATE - $TIME is $MYSQLBIN_OLD" >> $BACKUP_DIR/$DATE/mysql-bininfo.txt

$MYSQLADMIN -u$MYSQL_USER -p$MYSQL_PASSWORD flush-logs

cp -rf /home/mysql/$MYSQLBIN_OLD $BACKUP_DIR/$DATE/

