#!/usr/bin/env bash
NEW_VERSION=$1

cd $(dirname "$0")/../../

env_file=.env
export $(cat $env_file | xargs)

if [ $NEW_VERSION == $PG_VERSION ]
then
  echo "Already on PostgresQL $NEW_VERSION"
  exit 0
fi

echo "Switching to PostgresQL $NEW_VERSION from $PG_VERSION"
sh $(dirname "$0")/dump.sh
sed -i '' -e "s/PG_VERSION=[[:digit:]]*/PG_VERSION=$NEW_VERSION/" $env_file

psql_data_folder=~/postgresql/postgresql@$NEW_VERSION
echo $psql_data_folder

if [ -d "$psql_data_folder" ]
then
  if [[ "$(ls -A $psql_data_folder)" ]]
  then
    rm -rf $psql_data_folder
    mkdir $psql_data_folder
  fi
else
  mkdir $psql_data_folder
fi

export $(cat $env_file | xargs)

docker compose up -d --build

RETRIES=10
until psql -U postgres > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
  sleep 1
done

sh $(dirname "$0")/restore.sh
