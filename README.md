# ubuntu-mysql-backup

This repository contains a few scripts for automating backups with Percona Xtrabackup

## Changes to original

-   Changed directories
-   Removed scripts not related to original [Original How to](https://www.digitalocean.com/community/tutorials/how-to-configure-mysql-backups-with-percona-xtrabackup-on-ubuntu-16-04)
-   Added script that
    -   installs `Percona Xtrabackup`
    -   creates mysql backup user
    -   creates encryption_key

```bash
bash prepare-env.sh
```

## Notes

-   uses `percona-xtrabackup-24`
-   for mysql 5 (not 8)

# Docs

-   [Installing Percona XtraBackup on Debian and Ubuntu](https://www.percona.com/doc/percona-xtrabackup/2.4/installation/apt_repo.html)
