#!/bin/bash

# Add your backup dir location, password, mysql location and mysqldump location
DATE=$(date +%d-%m-%Y)
YEST=$(date --date="yesterday" +"%d-%m-%Y")
TIME=$(date +"%r")
BACKUP_DIR="/home/backup"
MYSQL_DIR="/home/mysql"  #Default location is /var/lib/mysql
MYSQL_USER="root"
MYSQL_PASSWORD="drRdhkr46"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
MYSQLADMIN=/usr/bin/mysqladmin

# To create a new directory into backup directory location
mkdir -p $BACKUP_DIR/$DATE

# To generate name of mysql-bin file before full backup
MYSQLBIN_OLD=`ls -lrth $MYSQL_DIR | grep mysql-bin.* | awk '{ print $9 }' | egrep -v "mysql-bin.index" | tail -n 1`
echo "The mysql-bin file before backup on $DATE - $TIME is $MYSQLBIN_OLD" > $BACKUP_DIR/$DATE/mysql-bininfo.txt

# get a list of databases
databases=`$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|mysql|information_schema|performance_schema)"`
echo $databases
# dump each database in separate name
for db in $databases; do
echo $db
$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db --single-transaction --master-data=2 > "$BACKUP_DIR/$DATE/$db.sql"
done

# To generate new mysql-bin file for incremental backup
$MYSQLADMIN -u$MYSQL_USER -p$MYSQL_PASSWORD flush-logs

# To generate name of mysql-bin file after full backup
MYSQLBIN_NEW=`ls -lrth $MYSQL_DIR | grep mysql-bin.* | awk '{ print $9 }' | egrep -v "mysql-bin.index" | tail -n 1`
echo "The mysql-bin file after full backup on $DATE - $TIME is $MYSQLBIN_NEW" >> $BACKUP_DIR/$DATE/mysql-bininfo.txt

#Comressing yesterday's backup directory
tar -cvzf $BACKUP_DIR/$YEST.tar.gz $BACKUP_DIR/$YEST
rm -rf $BACKUP_DIR/$YEST/

# Delete files older than 10 days
find $BACKUP_DIR/* -mtime +10 -exec rm -rf {} \;
