service ssh restart

POSTGRES_HOME=/var/lib/postgresql
ssh-keygen -q -t rsa -N '' -f $POSTGRES_HOME/.ssh/id_rsa

mkdir -p $POSTGRES_HOME/backup_db \
  && echo "BACKUP_PATH=$POSTGRES_HOME/backup_db" >> $POSTGRES_HOME/.bash_profile \
  && echo "export BACKUP_PATH" >> $POSTGRES_HOME/.bash_profile \
  && echo "alias pg_probackup='pg_probackup-10'">>$POSTGRES_HOME/.bash_profile

chown postgres -R $POSTGRES_HOME
chown postgres $POSTGRES_HOME
