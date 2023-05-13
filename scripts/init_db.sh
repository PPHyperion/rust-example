#!/bin/bash
set -eo pipefail

if ! [ -x "$(command -v psql)" ]; then
  echo "Error: psql is not installed."
  exit 1
fi

if ! [ -x "$(command -v sqlx)" ]; then
	echo "Error: sqlx is not installed."
	echo "Use: "
	echo "  cargo install sqlx-cli \
    --no-default-features --features rustls,postgres"
	echo "to install it."
	exit 1
fi

DB_USER=${POSTGRES_USER:=postgres}
DB_PASSWORD="${POSTGRES_PASSWORD:=password}"
DB_NAME="${POSTGRES_DB:=newsletter}"
DB_PORT="${POSTGRES_PORT:=5432}"
DB_HOST="${POSTGRES_HOST:=localhost}"

if [[ -z "${SKIP_DOCKER}" ]]
then
	docker run \
		-e POSTGRES_USER="${DB_USER}" \
		-e POSTGRES_PASSWORD="${DB_PASSWORD}" \
		-e POSTGRES_DB="${DB_NAME}" \
		-p "${DB_PORT}":5432 \
		-d postgres:alpine \
		postgres -N 1000
fi

DATABASE_URL=postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
export DATABASE_URL

# Keep pinging Postgres until it's ready to accept commands
declare -i ctr=0
export PGPASSWORD="${DB_PASSWORD}"
until psql -h "${DB_HOST}" -U "${DB_USER}" -p "${DB_PORT}" -d "postgres" -c '\q' &>/dev/null; do
  if [ $ctr = 0 ]; then 
    echo "Postgres is still unavailable - sleeping"
    ctr+=1
  fi
  sleep 1
done

echo "Postgres is up and running on port ${DB_PORT}!"

sqlx database create
sqlx migrate run

echo "Postgres has been migrated, ready to go!"
