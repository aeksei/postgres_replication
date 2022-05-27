POSTGRES_HOME=/var/lib/postgresql
mkdir -p $POSTGRES_HOME/backup_db \
  && echo "BACKUP_PATH=$POSTGRES_HOME/backup_db" >> $POSTGRES_HOME/.bash_profile \
  && echo "export BACKUP_PATH" >> $POSTGRES_HOME/.bash_profile \
  && echo "alias pg_probackup='pg_probackup-10'">>$POSTGRES_HOME/.bash_profile \
  && . $POSTGRES_HOME/.bash_profile

su postgres

pg_probackup init
pg_probackup add-instance --instance=db1 --remote-host=master --remote-user=postgres --pgdata=/var/lib/postgresql/data
pg_probackup set-config --instance db1 --retention-window=7 --retention-redundancy=2

# on master
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


PG_HDA_CONF=/var/lib/postgresql/data/pg_hba.conf
echo "# pg_probackup access permission" >> $PG_HDA_CONF \
  && echo "host    backupdb   backup          replica        md5" >> $PG_HDA_CONF \
  && echo "host    replication  backup          replica        md5" >> $PG_HDA_CONF

psql -c 'select pg_reload_conf()'
psql -c 'select * from pg_hba_file_rules'

# on replica
echo "master:5432:replication:backup:postgres">>~/.pgpass
echo "master:5432:backupdb:backup:postgres">>~/.pgpass

chmod 600 ~/.pgpass

pg_probackup backup --instance=db1 -j2 --backup-mode=FULL --compress --stream --delete-expired --pguser=backup --pgdatabase=backupdb --remote-host=master --remote-user=postgres

pg_probackup set-config --instance=db1 --remote-host=master --remote-user=postgres --pguser=backup --pgdatabase=backupdb --log-filename=backup_cron.log --log-level-file=log --log-directory=$POSTGRES_HOME/backup_db/log


pg_probackup backup --instance=db1 -j2 --progress -b DELTA --compress --stream --delete-expired
