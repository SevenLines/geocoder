#!/usr/bin/env bash
set -e

cd /app
aria2c -o data.osm.pbf -x10 -s10 "$OSM_PBF_URL"

sed -i "/default_text_search_config/c default_text_search_config = 'pg_catalog.russian'" /var/lib/postgresql/data/postgresql.conf

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS hstore;
    CREATE EXTENSION IF NOT EXISTS pg_trgm;
EOSQL

imposm3 import -mapping mapping.yaml -dbschema-import public \
    -connection "postgis://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost/$POSTGRES_DB" \
    -read data.osm.pbf -write -overwritecache


psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"  < initdb.sql