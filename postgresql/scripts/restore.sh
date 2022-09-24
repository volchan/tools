#!/bin/bash

cd $(dirname "$0")/../backups
file=$(ls | sort -n -k 2 | tail -1)
echo "Restoring $file"
cat $file | docker exec -i postgres psql -U postgres
echo "Restored $file"
cd -
