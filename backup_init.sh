#!/bin/bash

mkdir -p "$POSTGRES_HOME"/backup_db \
  && echo BACKUP_PATH="$POSTGRES_HOME"/backup_db >> "$POSTGRES_HOME"/.bash_profile \
  && echo export BACKUP_PATH >> "$POSTGRES_HOME"/.bash_profile \
  && echo alias pg_probackup='pg_probackup-10' >> "$POSTGRES_HOME"/.bash_profile

echo . "$POSTGRES_HOME"/.bash_profile >> "$POSTGRES_HOME"/.bashrc

. "$POSTGRES_HOME"/.bash_profile
pg_probackup-10 init
pg_probackup-10 add-instance --instance=db1 --remote-host=master --remote-user=postgres --pgdata=/var/lib/postgresql/data
pg_probackup-10 set-config --instance db1 --retention-window=7 --retention-redundancy=2
pg_probackup-10 set-config --instance=db1 --remote-host=master --remote-user=postgres --pguser=backup --pgdatabase=backupdb --log-filename=backup_cron.log --log-level-file=log --log-directory=$POSTGRES_HOME/backup_db/log

echo "master:5432:replication:backup:postgres">>~/.pgpass
echo "master:5432:backupdb:backup:postgres">>~/.pgpass
chmod 600 ~/.pgpass

chown postgres -R "$POSTGRES_HOME"
