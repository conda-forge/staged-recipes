#!/bin/bash

# this script is based off the homebrew package:
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mysql.rb

echo "MySQL Installation Notes:

1. WARNING: MySQL has been installed without a root password. To secure the
   installation, run:

    mysql_secure_installation

2. By default, MySQL will only allow connections from localhost.

3. To start [stop] the server, run:

    mysql.server start [stop]

4. The MySQL data directory is located within your Conda environment. This
   means that if your Conda environment is deleted, any databases will be
   deleted too!" >> ${PREFIX}/.messages.txt

# Initialize the server if needed.
if [ ! -e ${PREFIX}/mysql/datadir/mysql/user.frm ]
then
    ${PREFIX}/bin/mysqld \
        --initialize-insecure \
        --user=${USER} \
        --basedir=${PREFIX} \
        --datadir=${PREFIX}/mysql/datadir \
        --lc-messages-dir=${PREFIX}/mysql/lc_messages_dir \
        --character-sets-dir=${PREFIX}/mysql/charsets \
        --plugin-dir=${PREFIX}/mysql/plugin
    echo "Initialized MySQL server data directory." >> ${PREFIX}/.messages.txt
else
    echo "MySQL server data directory already exists. No initialization was done." >> ${PREFIX}/.messages.txt
fi
