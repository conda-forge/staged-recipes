#!/bin/bash

SQL_SCRIPT="$PREFIX/share/nxsconfigserver/mysql_create.sql"

if [ ! -f "$SQL_SCRIPT" ]; then
    echo "Error: SQL script not found at $SQL_SCRIPT" >> "$PREFIX/.messages.txt"
    exit 1
fi

# MYSQL_PWD, MYSQL_HOST, and MYSQL_USER variables needs to be set 

mysql -u root -e "CREATE DATABASE IF NOT EXISTS my_database;" 2>> "$PREFIX/.messages.txt"
mysql -u root my_database < "$SQL_SCRIPT" 2>> "$PREFIX/.messages.txt"

echo "Database 'my_database' successfully initialized." >> "$PREFIX/.messages.txt"
