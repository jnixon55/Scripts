#!/bin/bash


########################################################
### This process will take up to 7 hours to complete ###
########################################################



#Import new postgres to restore slave replication As Root User
chown postgres:postgres /mnt/backup/masterdb_replication_20130921.tar

#As Postgres User
su - postgres
/data/pgsql/bin/pg_ctl -D /data/pgsql/data -m fast stop
mv /data/pgsql/data/ /mnt/backup/data.old2
exit

#As Root User
cd /data
tar xvfp /mnt/backup/masterdb_replication_20130921.tar
mv /data/data/pgsql/data /data/pgsql/
rm -f /data/pgsql/data/postmaster.pid
vim /data/pgsql/data/postgresql.conf
     hot_standby = on
cp /home/postgres/recovery.conf /data/pgsql/data/recovery.conf


#As Root User
chown -R postgres:postgres /data/pgsql
su - postgres
/data/pgsql/bin/pg_ctl -D /data/pgsql/data -l /data/pgsql/logs/logfile start

