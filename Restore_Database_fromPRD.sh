#!/bin/bash


#DB restore for PRE DBS31

TODAY=`date +%Y%m%d`

#Drop Database
su - postgres
dropdb unicorn
dropdb unicorn-3rdparty
dropdb zebra


#Create new Unicorn Database
#su - postgres
#createdb -E UTF8 -T template0 unicorn
#createdb -E UTF8 -T template0 unicorn-3rdparty
#createdb -E UTF8 -T template0 zebra


#Restore Database
su - postgres
pg_restore -d unicorn --jobs=4 -O /data/backup/backupdata/zebra-$TODAY.psql
pg_restore -d unicorn --jobs=4 -O /data/backup/backupdata/unicorn-3rdparty-$TODAY.psql
pg_restore -d unicorn --jobs=4 -O /data/backup/backupdata/unicorn-$TODAY.psql

#Only run this on the PRE environment
#need to create a .sql that will disable all Quartz jobs (must verify if this needs to be done still)

#--disabling all Quartz jobs

#BEGIN;
#update q_trigger set enabled = false;
#update q_trigger_job set enabled = false;
#delete from qrtz_simple_triggers;
#delete from qrtz_cron_triggers;
#delete from qrtz_triggers;
#delete from qrtz_fired_triggers;
#delete from qrtz_scheduler_state; 
#COMMIT;
psql -f /


#Re-Sync Replication between master and slave database
su - postgres
psql -c "SELECT pg_start_backup('label', true)"
tar cfP /mnt/backup/masterdb_replication_20130921.tar /data/pgsql/data
psql -c "SELECT pg_stop_backup();"
exit


#
scp -i /root/.ssh/id_rsa /mnt/backup/masterdb_replication_20130921.tar root@cycawspredbs32:/mnt/backup/
