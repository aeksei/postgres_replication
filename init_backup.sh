su postgres

POSTGRES_HOME=/var/lib/postgresql
. $POSTGRES_HOME/.bash_profile

pg_probackup init
pg_probackup add-instance --instance=db1 --remote-host=master --remote-user=postgres --pgdata=/var/lib/postgresql/data
pg_probackup set-config --instance db1 --retention-window=7 --retention-redundancy=2
pg_probackup set-config --instance=db1 --remote-host=master --remote-user=postgres --pguser=backup --pgdatabase=backupdb --log-filename=backup_cron.log --log-level-file=log --log-directory=$POSTGRES_HOME/backup_db/log


echo "master:5432:replication:backup:postgres">>~/.pgpass
echo "master:5432:backupdb:backup:postgres">>~/.pgpass

chmod 600 ~/.pgpass


# on master
su postgres
createdb backupdb
psql -d backupdb

BEGIN;
CREATE ROLE backup WITH LOGIN REPLICATION password 'postgres';
GRANT USAGE ON SCHEMA pg_catalog TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.current_setting(text) TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.pg_is_in_recovery() TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.pg_start_backup(text, boolean, boolean) TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.pg_stop_backup(boolean, boolean) TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.pg_create_restore_point(text) TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.pg_switch_wal() TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.pg_last_wal_replay_lsn() TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.txid_current() TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.txid_current_snapshot() TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.txid_snapshot_xmax(txid_snapshot) TO backup;
GRANT EXECUTE ON FUNCTION pg_catalog.pg_control_checkpoint() TO backup;
COMMIT;
\q

PG_HDA_CONF=/var/lib/postgresql/data/pg_hba.conf
echo "# pg_probackup access permission" >> $PG_HDA_CONF \
  && echo "host    backupdb   backup          all        md5" >> $PG_HDA_CONF \
  && echo "host    replication  backup          all        md5" >> $PG_HDA_CONF

psql -c 'select pg_reload_conf()'
psql -c 'select * from pg_hba_file_rules'

psql -c 'alter system set archive_mode = on'
psql -c "alter system set archive_command = 'pg_probackup-10 archive-push -B /var/lib/postgresql/backup_db --instance=db1 --wal-file-path=%p --wal-file-name=%f --remote-host=replica --remote-user=postgres --compress';"



# on replica

pg_probackup backup --instance=db1 -j 2 --progress -b FULL --compress --delete-expired --delete-wal
pg_probackup backup --instance=db1 -j 2 --progress -b PAGE --compress --delete-expired --delete-wal


psql -c 'create table timing(time_now timestamp with time zone)'
psql -c 'insert into timing(select now())'
psql -c 'insert into timing(select now())'
psql -c 'insert into timing(select now())'


pg_probackup set-config --instance db1 --archive-host=replica --archive-user=postgres
pg_probackup restore --instance=db1 -D /var/lib/postgresql/data/ -j 2 --recovery-target-time="2022-06-02 10:42:54+00" --progress --remote-proto=ssh --remote-host=master --log-level-console=log --log-level-file=verbose --log-filename=restore_time.log



psql -c 'select * from timing'

