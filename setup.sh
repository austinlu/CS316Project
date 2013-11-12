#!/bin/bash

# create new database
dropdb pollugraphics
createdb pollugraphics

# create database tables
python django/manage.py syncdb

# load data into tables
psql -af "COPY state FROM '${PWD}data/stateTable.csv' DELIMTER ',' CSV"
psql -af "COPY county FROM '${PWD}data/countyTable.csv' DELIMTER ',' CSV"
psql -af "COPY facility FROM '${PWD}data/facilityTable.csv' DELIMTER ',' CSV"
psql -af "COPY facilitypollution FROM '${PWD}data/facilityPollutionTable.csv' DELIMTER ',' CSV"