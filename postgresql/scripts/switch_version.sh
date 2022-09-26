#!/usr/bin/env bash

help()
{
  echo "
    Usage: switch_version [-v version] [-d] [-r] [-h]

    -v version     Version to deploy.
    -d             Dump all databases.
    -r             Restore all databases.

    For Example: switch_version -v 14 -d -r

    -h              Help
  "
  exit 0
}

OPTS=$(getopts ":v:drh" flag)

VALID_ARGUMENTS=$# # Returns the count of arguments that are in short or long options

if [ "$VALID_ARGUMENTS" -eq 0 ]; then
  help
fi

dump=false
restore=false

while getopts "v:drh" flag;do
  echo "flag -$flag, Argument $OPTARG";
  case $flag in
    v)
      NEW_VERSION="$OPTARG"
      ;;
    d)
      echo "HEllo"
      dump=true
      ;;
    r)
      restore=true
      ;;
    h)
      help
      ;;
    *)
      help
      ;;
  
  esac
done

echo "$dump $restore"

echo "Switching to PostgresQL $NEW_VERSION"

cd $(dirname "$0")/../../

env_file=.env
export $(cat $env_file | xargs)

if [ $NEW_VERSION == $PG_VERSION ]
then
  echo "Already on PostgresQL $NEW_VERSION"
  exit 0
fi

echo "Switching to PostgresQL $NEW_VERSION from $PG_VERSION"
if $dump
then
  sh $(dirname "$0")/dump.sh
fi
sed -i '' -e "s/PG_VERSION=[[:digit:]]*/PG_VERSION=$NEW_VERSION/" $env_file

if $restore
then
  psql_data_folder=~/postgresql/postgresql@$NEW_VERSION
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
fi

export $(cat $env_file | xargs)

docker compose up -d --build postgres

if $restore
then
  RETRIES=10
  until docker exec -it postgres psql -h localhost -U postgres -d postgres -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
    echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
    sleep 1
  done

  sh $(dirname "$0")/restore.sh
fi
