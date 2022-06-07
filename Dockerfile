FROM postgres:10.21

RUN apt-get update \
  && apt-get install -y lsb-core wget apt-transport-https keychain openssh-server openssh-client \
  && sh -c 'echo "deb [arch=amd64] https://repo.postgrespro.ru/pg_probackup/deb/ $(lsb_release -cs) main-$(lsb_release -cs)" > /etc/apt/sources.list.d/pg_probackup.list' \
  && wget -O - https://repo.postgrespro.ru/pg_probackup/keys/GPG-KEY-PG_PROBACKUP | apt-key add - \
  && apt-get update \
  && apt-get install pg-probackup-10 \
  && apt-get install pg-probackup-10-dbg \
  && apt-get clean

ENV POSTGRES_HOME=/var/lib/postgresql
RUN mkdir $POSTGRES_HOME/.ssh
RUN ssh-keygen -q -t rsa -N '' -f $POSTGRES_HOME/.ssh/id_rsa

RUN mkdir -p $POSTGRES_HOME/backup_db \
  && echo "BACKUP_PATH=$POSTGRES_HOME/backup_db" >> $POSTGRES_HOME/.bash_profile \
  && echo "export BACKUP_PATH" >> $POSTGRES_HOME/.bash_profile \
  && echo "alias pg_probackup='pg_probackup-10'">>$POSTGRES_HOME/.bash_profile \
  && chown postgres -R $POSTGRES_HOME

COPY init_backup.sh ./init_backup.sh
RUN chmod +x ./init_backup.sh

COPY master_postgresql.conf /etc/postgresql/postgresql.conf

ENTRYPOINT service ssh restart && ./docker-entrypoint.sh postgres
