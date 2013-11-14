#!/bin/bash

set -e

dropdb pollugraphics || true
# create new database
createdb pollugraphics

# create database tables
python django/manage.py syncdb

# load data into tables
psql pollugraphics -ac "COPY state FROM '${PWD}/data/stateTable.csv' DELIMITER ',' CSV"
psql pollugraphics -ac "COPY county FROM '${PWD}/data/countyPkTable.csv' DELIMITER ',' CSV"
psql pollugraphics -ac "COPY facility FROM '${PWD}/data/facilityTable.csv' DELIMITER ',' CSV"
psql pollugraphics -ac "COPY facilitypollution FROM '${PWD}/data/facilitypollutionTable.csv' DELIMITER ',' CSV"
