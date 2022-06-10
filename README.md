# HOW TO USE

[Официальная документация](https://postgrespro.ru/docs/postgrespro/10/app-pgprobackup)

## Установка pg_probackup-10
1. Для работы pg_probackup-10 должна быть одинаковой версии на машине с базой и на машине с удаленным подключением
1. [Инструкция](https://github.com/postgrespro/pg_probackup#pg_probackup-for-vanilla-postgresql) по установке pg_probackup-10
1. Между машинами должно быть настроено подключение через ssh ключи. В обе стороны

## Настройка базы
1. Скрипт `master_init` содержит инструкции для первоначальной настройки базы с которой будет делаться бекап
1. Для архивирования WAL файлов база должна иметь настройки из файла `master_postgresql.conf`

## Настройка удаленного хоста
1. На удаленной машине следует инициализировать настройки, с указанием 
   - `--remote-host` - хоста с БД
    - `--remote-user` - ssh пользователя для подключения к БД
    - `--pgdata` - папка с данными БД
    ```
    pg_probackup-10 init
    pg_probackup-10 add-instance --instance=db1 --remote-host=master --remote-user=postgres --pgdata=/var/lib/postgresql/data
    ```
   
1. Чтобы не повторять настройки при каждом бекапе, необходимо выполнить настройки:
   - `--pguser=backup` - пользователь, из-под которого будет выполняться бекап
   - `--pgdatabase=backupdb` - база, которая будет бекапиться
   ```
   pg_probackup-10 set-config --instance=db1 --remote-host=master --remote-user=postgres --pguser=backup --pgdatabase=backupdb --log-filename=backup_cron.log --log-level-file=log --log-directory=$POSTGRES_HOME/backup_db/log
   ```
1. В файле `.pgpass` должны храниться учетки для подключения к базе
1. Скрипт `backup_init` содержит инструкции для первоначальной настройки удаленной машины, на которой будут бекапы

## Создание бекапа базы
1. Для того, чтобы сделать полный бекап базы, следует выполнить команду
    ```shell
    pg_probackup backup --instance=db1 -j 2 --progress -b FULL --compress --delete-expired --delete-wal
    ```
1. Для того, чтобы сделать инкрементальный бекап базы, следует выполнить команду
    ```shell
    pg_probackup backup --instance=db1 -j 2 --progress -b PAGE --compress --delete-expired --delete-wal
    ```
   
## Откат бекапа
1. Для того чтобы откатиться до бекапа следует указать настройки
    - `--archive-host=replica` - хост, где лежат бекапы
    - `--archive-user=postgres` - пользователь, который имеет доступ к бекапам
    ```shell
    pg_probackup set-config --instance db1 --archive-host=replica --archive-user=postgres
    ```
1. Команда, позволяющая увидеть доступные бекапы
    ```shell
    pg_probackup show
    ```
1. Команды, позволяющие проверить возможность и откатиться до указанного бекапа в аргументе `-i`
    - `-D /var/lib/postgresql/data/` - папка для восстановления данных
    - `--remote-host=master` - хост с базой
    ```shell
    pg_probackup validate --instance=db1 -i RD3PFQ
    pg_probackup restore --instance=db1 -D /var/lib/postgresql/data/ -j 2 -i RD3PFQ --progress --remote-proto=ssh --remote-host=master --log-level-console=log --log-level-file=verbose --log-filename=restore_time.log
    ```
1. Команды, позволяющие проверить возможность и откатиться от указанного бекапа в аргументе `-i` до времени `--recovery-target-time`
    ```shell
    pg_probackup validate --instance=db1 -i RD3PFQ --recovery-target-time="2022-06-07 09:39:11+00"
    pg_probackup restore --instance=db1 -D /var/lib/postgresql/data/ -j 2 -i RD3PFQ --recovery-target-time="2022-06-07 09:39:11+00" --progress --remote-proto=ssh --remote-host=master --log-level-console=log --log-level-file=verbose --log-filename=restore_time.log
    ```