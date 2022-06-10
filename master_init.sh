#!/bin/bash
set -e

# создается тестовая база для бекапа
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE DATABASE backupdb;
EOSQL

# база для бекапа
BKP_DATABASE=backupdb

# создается пользователь для подключения к базе и выполнения бекапа
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$BKP_DATABASE" <<-EOSQL
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
  GRANT SELECT ON TABLE pg_catalog.pg_database TO backup;
  COMMIT;
EOSQL

# настройка для удаленного подключения
PG_HDA_CONF=/var/lib/postgresql/data/pg_hba.conf
echo "# pg_probackup access permission" >> $PG_HDA_CONF \
  && echo "host    backupdb   backup          all        md5" >> $PG_HDA_CONF \
  && echo "host    replication  backup          all        md5" >> $PG_HDA_CONF

psql -c 'select pg_reload_conf()'
psql -c 'select * from pg_hba_file_rules'
