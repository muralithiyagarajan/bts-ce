#!/bin/bash
#
#Create  database base user and database
#
#Licence Apache 2.0
#Author Emmanuel Robert Ssebaggala <emmanuel.ssebaggala@bodastage.com>
#/r/n
#

#set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER bodastage WITH PASSWORD 'password';
    CREATE DATABASE bts owner bodastage;
	
    CREATE USER airflow WITH PASSWORD 'airflow';
    CREATE DATABASE airflow owner airflow;
	ALTER ROLE airflow SET search_path = 'public';

	-- CREATE EXTENSION tablefunc;

EOSQL

# Create functions in bodastage schema
psql -v ON_ERROR_STOP=1 --username "bodastage" --password "password" --dbname "bts"  <<-'EOSQL'

   -- Hex to integer
    CREATE OR REPLACE FUNCTION hex_to_int(hexval varchar) RETURNS integer AS $$
    DECLARE
       result  int;
    BEGIN
     EXECUTE 'SELECT x''' || hexval || '''::int' INTO result;
     RETURN result;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE STRICT;

	-- HEX to character/string
    CREATE OR REPLACE FUNCTION hex_to_char(hexval varchar) RETURNS integer AS $$
    DECLARE
       result  varchar;
    BEGIN
     EXECUTE 'SELECT x''' || hexval || '''::int' INTO result;
     RETURN result;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE STRICT;
EOSQL
