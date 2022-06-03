#! /bin/sh
. "$POSTGRES_HOME"/.bash_profile
pg_probackup backup --instance=db1 -j 2 --progress -b $1 --compress --delete-expired --delete-wal

## on replica
#
#pg_probackup backup --instance=db1 -j 2 --progress -b FULL --compress --delete-expired --delete-wal
#pg_probackup backup --instance=db1 -j 2 --progress -b PAGE --compress --delete-expired --delete-wal
#
#
#psql -c 'create table timing(time_now timestamp with time zone)'
#psql -c 'insert into timing(select now())'
#psql -c 'insert into timing(select now())'
#psql -c 'insert into timing(select now())'
#
#
#pg_probackup set-config --instance db1 --archive-host=replica --archive-user=postgres
#pg_probackup restore --instance=db1 -D /var/lib/postgresql/data/ -j 2 --recovery-target-time="2022-06-02 10:42:54+00" --progress --remote-proto=ssh --remote-host=master --log-level-console=log --log-level-file=verbose --log-filename=restore_time.log
#
#
#
#psql -c 'select * from timing'

