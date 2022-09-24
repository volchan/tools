#!/usr/bin/env bash

cd $(dirname "$0")/../backups
file=$(date +"%Y%m%d%I%M%S").dump.sql
echo $file
docker exec -i postgres /usr/bin/pg_dumpall -U postgres > $file
grep -v "CREATE ROLE postgres;" $file > tmpfile && mv tmpfile $file
grep -v "ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;" $file > tmpfile && mv tmpfile $file
cd -
