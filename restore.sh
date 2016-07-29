#!/bin/bash

/data/pgsql/transfer/restore/restoreMailer.sh &

TFILE=/data/pgsql/transfer/restore/time.txt
IFILE=/data/pgsql/transfer/restore/iostat.log
DBSERV=cycawspredbs31

echo "Start scp..." > $TFILE
echo "Start scp..." > $IFILE
/bin/date >> $TFILE

TODAY=`date +%Y%m%d`
#/usr/bin/scp -i /home/cycleon/.ssh/id_rsa root@$DBSERV:/data/backup/backupdata/unicorn-$TODAY.psql /data/pgsql/dumps/9m
/usr/bin/scp -i /home/cycleon/.ssh/id_rsa root@$DBSERV:/mnt/backupdata/unicorn-$TODAY.psql /data/pgsql/dumps/

if [ -f /data/pgsql/dumps/unicorn-$TODAY.psql ]; then
        echo "File exists. Restore continues."
else
        echo "File doesn't exist, will cause error mentioning Permissions. Restore aborted."
        exit
fi

/usr/bin/find /data/pgsql/dumps/ -type f -name "*.psql" -ctime +1 -exec rm '{}' \;

echo "Start restore..." >> $TFILE
echo "Start restore..." >> $IFILE
/bin/date >> $TFILE
#/usr/local/pgsql/script/pg_kill_connections.sh unicorn-transfer
/data/pgsql/bin/dropdb unicorn-backup
/data/pgsql/bin/dropdb unicorn-transfer
/data/pgsql/bin/createdb -E UTF8 -T template0 unicorn-transfer
echo "pg_restore unicorn-transfer begin" >> $TFILE
echo "pg_restore unicorn-transfer begin" >> $IFILE
/bin/date >> $TFILE
restoreOutput=$( { /data/pgsql/bin/pg_restore -d unicorn-transfer --jobs=4 -O /data/pgsql/dumps/unicorn-$TODAY.psql; } 2>&1 | tee -a "$TFILE" | grep -Ee 'FATAL:|ERROR:' | wc -l )
#/usr/local/pgsql/bin/pg_restore -d unicorn-transfer -O /usr/local/pgsql/dumps/unicorn-$TODAY.psql >> $TFILE
echo "pg_restore unicorn-transfer end" >> $TFILE
echo "pg_restore unicorn-transfer end" >> $IFILE
echo "Start vacuumdb..." >> $TFILE
echo "Start vacuumdb..." >> $IFILE
/bin/date >> $TFILE
#vacuum
/data/pgsql/bin/vacuumdb -d unicorn-transfer -z -v

echo "restoreOutput: $restoreOutput" >> $TFILE
echo "restoreOutput: $restoreOutput" >> $IFILE

if [ "$restoreOutput" -gt "0" ];then
echo "Restoring the new snapshot failed! The restore is stopping.." >> $TFILE
echo "Restoring the new snapshot failed! The restore is stopping.." >> $IFILE
exit
fi

echo "Client schema..." >> $TFILE
echo "Client schema..." >> $IFILE
/bin/date >> $TFILE
#add schemas populate client schema
/data/pgsql/bin/psql -d unicorn-transfer < /data/pgsql/transfer/restore/create_client_schema.sql
/data/pgsql/bin/psql -d unicorn-transfer < /data/pgsql/transfer/restore/populate_client_schema.sql

echo "Warehouse schema..." >> $TFILE
echo "Warehouse schema..." >> $IFILE
/bin/date >> $TFILE
#add schemas populate warehouse schema
/data/pgsql/bin/psql -d unicorn-transfer < /data/pgsql/transfer/restore/create_warehouse_schema.sql
/data/pgsql/bin/psql -d unicorn-transfer < /data/pgsql/transfer/restore/populate_warehouse_schema.sql

echo "Creating edi table..." >> $TFILE
echo "Creating edi table..." >> $IFILE
/bin/date >> $TFILE
#create edi table
/data/pgsql/bin/psql -d unicorn-transfer < /data/pgsql/transfer/restore/create_edi_table.sql

##write lockfile
/usr/bin/touch /var/www/lock
/usr/bin/touch /var/www/jboss_stopped

echo "Final stage..." >> $TFILE
echo "Final stage..." >> $IFILE
/bin/date >> $TFILE

#shutdown pentaho and arion
#Call22557 /usr/local/liferay/cycleon/liferay-portal-6.1.0-ce-ga1/tomcat-7.0.23/bin/shutdown.sh
# call 22521 arion runs on app15
/data/pentaho/biserver-ce/stop-pentaho.sh
#ssh cycleon@app15 /usr/local/liferay/cycleon/liferay-portal-6.1.0-ce-ga1/tomcat-7.0.23/bin/shutdown.sh
/bin/sleep 120;
/usr/bin/killall -9 java -u cycleon
#ssh cycleon@app15 /usr/bin/killall -9 java -u cycleon

# Kill all connections
pkill -f unicorn-reporting

#rename database
#/usr/local/pgsql/script/pg_kill_connections.sh unicorn-reporting
#/usr/local/pgsql/bin/psql -d postgres < /usr/local/pgsql/transfer/restore/rename_database.sql #Vervangen door rename_database.sh
/data/pgsql/transfer/restore/rename_database.sh >> $TFILE

#startup pentaho and arion
/data/pentaho/biserver-ce/start-pentaho.sh
#Call22557 /usr/local/liferay/cycleon/liferay-portal-6.1.0-ce-ga1/tomcat-7.0.23/bin/startup.sh
# call 22521 arion runs on app15
# Federico: temporarily disable Liferay startup, call 24253
#ssh cycleon@app15 /usr/local/liferay/cycleon/liferay-portal-6.1.0-ce-ga1/tomcat-7.0.23/bin/startup.sh
/bin/date >> /data/pgsql/transfer/restore/time.txt
##

##remove lockfile
/bin/sleep 240;
/bin/rm -f /var/www/lock
/usr/bin/touch /var/www/jboss_started

echo "Start Vacuum #2..." >> $TFILE
echo "Start Vacuum #2..." >> $IFILE
/bin/date >> $TFILE
/data/pgsql/bin/vacuumdb -d unicorn-reporting -z

DAYOFMONTH=`date +%d`
if [ "$DAYOFMONTH" == 01 ]; then
        echo "Start Create models..." >> $TFILE
        echo "Start Create models..." >> $IFILE
        /data/pentaho/weka/create_models.sh
        echo $? > /var/log/nagios-nrpe/create_models.log
fi

echo "Done" >> $TFILE
echo "Done" >> $IFILE
/bin/date >> $TFILE

#Update unicorn-reporting database with cycleon_ro user access
/data/pgsql/bin/psql -d unicorn-reporting < /data/pgsql/transfer/restore/update_reporting_cycleon_ro_user.sql