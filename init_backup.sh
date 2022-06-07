#! /bin/sh
. "$POSTGRES_HOME"/.bash_profile
pg_probackup backup --instance=db1 -j 2 --progress -b $1 --compress --delete-expired --delete-wal

## on replica
#
pg_probackup backup --instance=db1 -j 2 --progress -b FULL --compress --delete-expired --delete-wal
pg_probackup backup --instance=db1 -j 2 --progress -b PAGE --compress --delete-expired --delete-wal
#
#
psql -c 'create table timing(time_now timestamp with time zone)'
psql -c 'insert into timing(select now())'
psql -c 'insert into timing(select now())'
psql -c 'insert into timing(select now())'
#
#
pg_probackup set-config --instance db1 --archive-host=replica --archive-user=postgres
pg_probackup restore --instance=db1 -D /var/lib/postgresql/data/ -j 2 --recovery-target-time="2022-06-06 11:41:00+00" --progress --remote-proto=ssh --remote-host=master --log-level-console=log --log-level-file=verbose --log-filename=restore_time.log
#
#
#
#psql -c 'select * from timing'


pg_probackup backup --instance=db1 -j 2 --progress -b FULL --compress --delete-expired --delete-wal
pg_probackup validate --instance=db1 --recovery-target-time="2022-06-06 11:40:05+00"
pg_probackup validate --instance=db1 -i RD3NKY --recovery-target-time="2022-06-07 08:59:12"
pg_probackup restore --instance=db1 -D /var/lib/postgresql/data/ -j 2 --recovery-target-time="2022-06-06 11:40:05+00" --progress --remote-proto=ssh --remote-host=master --log-level-console=log --log-level-file=verbose --log-filename=restore_time.log
pg_probackup restore --instance=db1 -D /var/lib/postgresql/data/ -j 2 -i RD3M65 --recovery-target-time="2022-06-07 08:35:30+00" --progress --remote-proto=ssh --remote-host=master --log-level-console=log --log-level-file=verbose --log-filename=restore_time.log




# latest
/usr/lib/postgresql/10/bin/postgres -c 'config_file=/etc/postgresql/postgresql.conf'



pg_probackup backup --instance=db1 -j 2 --progress -b FULL --compress --delete-expired --delete-wal
pg_probackup backup --instance=db1 -j 2 --progress -b PAGE --compress --delete-expired --delete-wal

# 2022-06-07 09:37:54.486929+00
# 2022-06-07 09:37:54.536828+00
# 2022-06-07 09:37:55.433456+00
# 2022-06-07 09:39:10.263003+00
# 2022-06-07 09:39:10.310786+00
# 2022-06-07 09:39:11.37293+00
# 2022-06-07 09:40:17.041535+00
# 2022-06-07 09:40:17.134654+00
# 2022-06-07 09:40:18.09222+00


pg_probackup set-config --instance db1 --archive-host=replica --archive-user=postgres
pg_probackup validate --instance=db1 -i RD3PFQ --recovery-target-time="2022-06-07 09:39:11+00"
pg_probackup restore --instance=db1 -D /var/lib/postgresql/data/ -j 2 -i RD3PFQ --recovery-target-time="2022-06-07 09:39:11+00" --progress --remote-proto=ssh --remote-host=master --log-level-console=log --log-level-file=verbose --log-filename=restore_time.log

pg_probackup validate --instance=db1 -i RD3PFQ --recovery-target-time="2022-06-07 09:40:18+00"
pg_probackup restore --instance=db1 -D /var/lib/postgresql/data/ -j 2 -i RD3PFQ --recovery-target-time="2022-06-07 09:40:18+00" --progress --remote-proto=ssh --remote-host=master --log-level-console=log --log-level-file=verbose --log-filename=restore_time.log
