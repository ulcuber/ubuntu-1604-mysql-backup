#!/bin/bash

USER=$(id --user --name)

mysql_backup_user=backup
parent_dir="/var/backups/mysql"
mysql_backup_config="/etc/mysql/backup.cnf"
encryption_key_file="${parent_dir}/encryption_key"

# Use this to echo to standard error
error () {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}

HAS_BACKUP_USER=$(grep -e "^backup" /etc/passwd)
if [[ -z ${HAS_BACKUP_USER} ]]; then
    error "No backup user found"
fi

HAS_BACKUP_GROUP=$(grep -e "^backup" /etc/group)
if [[ -z ${HAS_BACKUP_GROUP} ]]; then
    error "No backup group found"
fi

echo 'Enter mysql backup user password:'
read -s MYSQL_BACKUP_PASSWORD

if [[ -z ${MYSQL_BACKUP_PASSWORD} ]]; then
    error "No password specified"
fi

wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
sudo percona-release enable-only tools release
sudo apt-get update
sudo apt-get install percona-xtrabackup-24 qpress -y

sudo mysql -e "CREATE USER '${mysql_backup_user}'@'localhost' IDENTIFIED BY '${MYSQL_BACKUP_PASSWORD}';"
echo "Created mysql user \"${mysql_backup_user}\""
sudo mysql -e "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT, CREATE TABLESPACE, PROCESS, SUPER, CREATE, INSERT, SELECT ON *.* TO '${mysql_backup_user}'@'localhost';"
echo "Mysql user \"${mysql_backup_user}\" granted RELOAD, LOCK TABLES, REPLICATION CLIENT, CREATE TABLESPACE, PROCESS, SUPER, CREATE, INSERT, SELECT"
sudo mysql -e "FLUSH PRIVILEGES;"
echo "Mysql privileges flushed"
echo ""

sudo usermod -aG mysql backup
echo "\"backup\" user added to \"mysql\" group"
sudo usermod -aG backup ${USER}
echo "\"${USER}\" user added to \"backup\" group"
echo ""

sudo touch ${mysql_backup_config}
sudo chown ${USER}: ${mysql_backup_config}
echo "[client]" > ${mysql_backup_config}
echo "user=${mysql_backup_user}" >> ${mysql_backup_config}
echo "password=${MYSQL_BACKUP_PASSWORD}" >> ${mysql_backup_config}
sudo chown backup: ${mysql_backup_config}
sudo chmod 600 ${mysql_backup_config}
echo "Mysql backup config created"
echo ""

sudo mkdir -p ${parent_dir}
sudo chown backup:mysql ${parent_dir}
sudo chown ${USER}: ${encryption_key_file}
printf '%s' "$(openssl rand -base64 24)" > ${encryption_key_file}
sudo chown backup: ${encryption_key_file}
sudo chmod 600 ${encryption_key_file}
echo "Encryption key created"

sudo find /var/lib/mysql -type d -exec chmod 750 {} \;
