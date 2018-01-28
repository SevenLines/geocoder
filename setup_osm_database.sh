#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS hstore;
EOSQL

imposm3 import -mapping mapping.yaml -dbschema-import public \
    -connection "postgis://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost/$POSTGRES_DB" \
    -read data.osm.pbf -write -overwritecache


psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"  < set_buildings_relations_fields.sql