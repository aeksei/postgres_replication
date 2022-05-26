FROM postgres:10.21

RUN apt-get update \
  && apt-get install -y lsb-core wget apt-transport-https keychain openssh-server openssh-client \
  && sh -c 'echo "deb [arch=amd64] https://repo.postgrespro.ru/pg_probackup/deb/ $(lsb_release -cs) main-$(lsb_release -cs)" > /etc/apt/sources.list.d/pg_probackup.list' \
  && wget -O - https://repo.postgrespro.ru/pg_probackup/keys/GPG-KEY-PG_PROBACKUP | apt-key add - \
  && apt-get update \
  && apt-get install pg-probackup-10 \
  && apt-get install pg-probackup-10-dbg \
  && apt-get clean

COPY setup.sh ./setup.sh
RUN chmod +x ./setup.sh

ENTRYPOINT  ./setup.sh && ./docker-entrypoint.sh postgres
