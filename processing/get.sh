#!/bin/bash

sqlite3 ./crm.db <<!

.headers on

.mode csv

.output persons.txt

select id, here_name from persons;

!