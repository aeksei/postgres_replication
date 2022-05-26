service ssh restart

ssh-keygen -q -t rsa -N '' -f /var/lib/postgresql/.ssh/id_rsa
chown postgres -R /var/lib/postgresql/.ssh
