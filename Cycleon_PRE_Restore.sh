#!/bin/bash

#####################################################
## Automated DB restore for PRD DBS31 to PRE DBS31 ##
#####################################################


# Start the auto Mailer and continue
#/data/pgsql/transfer/restore/restoreMailer.sh &

TFILE=/data/prd_restore/time.txt
DBSERV1=cycawsprddbs31
DBSERV2=cycawspredbs32
SSHKEY_CYCLEON=/home/cycleon/.ssh/id_rsa
SSHKEY_ROOT=/root/.ssh/id_rsa
SSHKEY_POSTGRES=/root/.ssh/id_postgres_slave
TODAY=`date +%Y%m%d`

################################
## Steps for PREDBS31 Restore ##
################################

# Echo Start time
echo "`date`   Start scp..." > $TFILE

# Remove DB files older than 1 day
/usr/bin/find /mnt/backupdata/prd_dumps/ -type f -name "*.psql" -ctime +1 -exec rm '{}' \;

# Copy PRD Databases to PRE environment
/usr/bin/scp -i /home/cycleon/.ssh/id_rsa root@$DBSERV1:/mnt/backupdata/unicorn-$TODAY.psql /mnt/backupdata/prd_dumps/
/usr/bin/scp -i /home/cycleon/.ssh/id_rsa root@$DBSERV1:/mnt/backupdata/unicorn-3rdparty-$TODAY.psql /mnt/backupdata/prd_dumps/
/usr/bin/scp -i /home/cycleon/.ssh/id_rsa root@$DBSERV1:/mnt/backupdata/zebra-$TODAY.psql /mnt/backupdata/prd_dumps/
echo "`date`   scp completed..." >> $TFILE

if [ -f /mnt/backupdata/prd_dumps/unicorn-$TODAY.psql ]; then
        echo "`date`   Unicorn file exists. Restore continues." >> $TFILE
else
        echo "`date`   Unicorn file doesn't exist, will cause error mentioning Permissions. Restore aborted." >>$TFILE
        exit
fi

if [ -f /mnt/backupdata/prd_dumps/unicorn-3rdparty-$TODAY.psql ]; then
        echo "`date`   Unicorn-3rdparty file exists. Restore continues." >> $TFILE
else
        echo "`date`   Unicorn-3rdparty file doesn't exist, will cause error mentioning Permissions. Restore aborted." >> $TFILE
        exit
fi

if [ -f /mnt/backupdata/prd_dumps/zebra-$TODAY.psql ]; then
        echo "`date`   Zebra file exists. Restore continues." >> $TFILE
else
        echo "`date`   Zebra file doesn't exist, will cause error mentioning Permissions. Restore aborted." >> $TFILE
        exit
fi

# Remotely stop tomcat on the application servers
ssh -i /home/cycleon/.ssh/id_rsa root@cycawspreapp31 '/etc/init.d/stop_tomcat.pl'
echo "`date`   Tomcat stopped on cycawspreapp31..." >> $TFILE
ssh -i /home/cycleon/.ssh/id_rsa root@cycawspreapp32 '/etc/init.d/stop_tomcat.pl'
echo "`date`   Tomcat stopped on cycawspreapp32..." >> $TFILE
#ssh -i /home/cycleon/.ssh/id_rsa root@cycawspreapp34 '/etc/init.d/stop_tomcat.pl'
#echo "`date`   Tomcat stopped on cycawspreapp34..." >> $TFILE

# Stopping Postgres & PGBouncer to close open connections
su - postgres -c "/data/pgsql/bin/pg_ctl -D /data/pgsql/data -m fast stop"
echo "`date`   PostgreSQL stopped..." >> $TFILE

/etc/init.d/pgbouncer stop
pgbouncer_pid=$(ps auxwww | grep pgbouncer | grep -v grep | awk '{ print $2 }')
kill -9 $pgbouncer_pid
sleep 30
echo "`date`   PGBouncer stopped..." >> $TFILE

# Starting Postgres
su - postgres -c "/data/pgsql/bin/pg_ctl -D /data/pgsql/data -l /data/pgsql/logs/logfile start"
sleep 15
echo "`date`   Postgres started..." >>$TFILE

# Start the DB Restore process
echo "`date`   Start restore process..." >> $TFILE
echo "`date`   Dropping Databases" >> $TFILE
su - postgres -c "/data/pgsql/bin/dropdb unicorn"
su - postgres -c "/data/pgsql/bin/dropdb unicorn-3rdparty"
su - postgres -c "/data/pgsql/bin/dropdb zebra"
echo "`date`   Creating Databses" >> $TFILE
su - postgres -c "/data/pgsql/bin/createdb -E UTF8 -T template0 unicorn"
su - postgres -c "/data/pgsql/bin/createdb -E UTF8 -T template0 unicorn-3rdparty"
su - postgres -c "/data/pgsql/bin/createdb -E UTF8 -T template0 zebra"

# Restore Unicorn DB
echo "`date`   pg_restore unicorn begin" >> $TFILE
restoreOutput=$( { su - postgres -c "/data/pgsql/bin/pg_restore -d unicorn --jobs=4 -O /mnt/backupdata/prd_dumps/unicorn-$TODAY.psql"; } 2>&1 | tee -a "$TFILE" | grep -Ee 'FATAL:|ERROR:' | wc -l )
echo "`date`   pg_restore unicorn end" >> $TFILE

# Restore Unicorn-3rdParty DB
echo "`date`   pg_restore unicorn-3rdparty begin" >> $TFILE
restoreOutput=$( { su - postgres -c "/data/pgsql/bin/pg_restore -d unicorn-3rdparty --jobs=4 -O /mnt/backupdata/prd_dumps/unicorn-3rdparty-$TODAY.psql"; } 2>&1 | tee -a "$TFILE" | grep -Ee 'FATAL:|ERROR:' | wc -l )
echo "`date`   pg_restore unicorn-3rdparty end" >> $TFILE

# Restore Zebra DB
echo "`date`   pg_restore zebra begin" >> $TFILE
restoreOutput=$( { su - postgres -c "/data/pgsql/bin/pg_restore -d zebra --jobs=4 -O /mnt/backupdata/prd_dumps/zebra-$TODAY.psql"; } 2>&1 | tee -a "$TFILE" | grep -Ee 'FATAL:|ERROR:' | wc -l )
echo "`date`   pg_restore zebra end" >> $TFILE

# Start PGBouncer
su - postgres -c "/etc/init.d/pgbouncer start"
echo "`date`   PGBouncer Started" >> $TFILE
sleep 15

#Disabling all Quartz jobs
su - postgres -c "/data/pgsql/bin/psql -f /data/prd_restore/quartzdel.sql unicorn"
echo "`date`   Disabling Quartz Jobs in Unicorn Database" >> $TFILE

#Grant user permissions for cycleon_ro user
su - postgres -c "/data/pgsql/bin/psql -f /data/prd_restore/update_reporting_cycleon_ro_user_unicorn.sql unicorn"
su - postgres -c "/data/pgsql/bin/psql -f /data/prd_restore/update_reporting_cycleon_ro_user_zebra.sql zebra"
su - postgres -c "/data/pgsql/bin/psql -f /data/prd_restore/update_reporting_cycleon_ro_user_unicorn-3rdparty.sql unicorn-3rdparty"
echo "`date`   Granting user permission for cycleon_ro" >> $TFILE

# Remotely start tomcat on the application servers
ssh -i /home/cycleon/.ssh/id_rsa '/etc/init.d/start_tomcat.pl'
echo "`date`   Tomcat started on cycawspreapp31..." >> $TFILE
ssh -i /home/cycleon/.ssh/id_rsa root@cycawspreapp32 '/etc/init.d/start_tomcat.pl'
echo "`date`   Tomcat started on cycawspreapp32..." >> $TFILE
#ssh -i /home/cycleon/.ssh/id_rsa root@cycawspreapp34 '/etc/init.d/start_tomcat.pl'
#echo "`date`   Tomcat started on cycawspreapp34..." >> $TFILE


############################################
## Steps for Master and Slave Replication ##
############################################

echo "`date`   Starting Master and Slave Replication" >> $TFILE

# Stopping Postgres on Slave DB Server
echo "`date`   Stopping Postgres on cycawspredbs32" >> $TFILE
ssh -i $SSHKEY_POSTGRES postgres@$DBSERV2 '/data/pgsql/bin/pg_ctl -D /data/pgsql/data -m fast stop'
sleep 30
echo "`date`   Postgres Stopped on cycawspredbs32" >> $TFILE

# Start RSync from Master to Slave
echo "`date`   Starting Postgres Sync from cycawspredbs31 to cycawspredbs32" >> $TFILE
su - postgres -c "psql -f /home/postgres/restore_start.sql"
/usr/bin/rsync -cva -e "/usr/bin/ssh -i $SSHKEY_POSTGRES" --inplace --delete-after /data/pgsql/data/ postgres@$DBSERV2:/data/pgsql/data/
su - postgres -c "psql -f /home/postgres/restore_stop.sql"
echo "`date`   Postgres Sync completed" >> $TFILE

# Edit Postgres files on Slave DB Server
echo "`date`   Editing Postgres files on DB Server" >> $TFILE
ssh -i $SSHKEY_ROOT root@$DBSERV2 'rm -f /data/pgsql/data/postmaster.pid'
ssh -i $SSHKEY_ROOT root@$DBSERV2 'cp /home/postgres/postgresql.conf /data/pgsql/data/postgresql.conf'
ssh -i $SSHKEY_ROOT root@$DBSERV2 'cp /home/postgres/recovery.conf /data/pgsql/data/recovery.conf'
ssh -i $SSHKEY_ROOT root@$DBSERV2 'chown -R postgres:postgres /data/pgsql'

# Starting Postgres on Slave DB Server
echo "`date`   Starting Postgres on Slave DB Server" >> $TFILE
ssh -i $SSHKEY_POSTGRES postgres@$DBSERV2 '/data/pgsql/bin/pg_ctl -D /data/pgsql/data -l /data/pgsql/logs/logfile start'
sleep 15
echo "`date`   Postgres Started on Slave DB Server" >> $TFILE

# Script is completed
echo "`date`   Done" >> $TFILE