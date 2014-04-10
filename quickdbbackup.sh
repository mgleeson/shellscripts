#!/bin/bash
#### 
# quickdbbackup.sh
# A tiny mysql single db backup script 
# which outputs date/time stampted sql 
# files ideal for automation with cron
###
# enter relevant values for the 3 variables below
mysqlUsername="username"
mysqlPasswd="" # leave blank like this if you wish to be prompted for password instead
mysqlDbName="databasename" 
###
_now=$(date +%Y-%m-%d--%H:%M:%S)
_file="${mysqlDbName}_backup_$_now.sql"
mysqldump -u ${mysqlUsername} -p${mysqlPasswd} ${mysqlDbName} > "$_file"
