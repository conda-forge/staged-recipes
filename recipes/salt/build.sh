#!/bin/bash

$PYTHON setup.py install

# Create directory structure for salt
# These are ENV safe, because we created a custom
# _syspaths.py file

# this file re-maps the default paths for configs
cp $RECIPE_DIR/_syspaths.py $SP_DIR/salt

DIRECTORIES="etc/salt
var/cache/salt
var/run/salt
srv/salt
srv/pillar
var/log/salt
var/run
"
for path in $DIRECTORIES
do
    mkdir -p $PREFIX/$path
    touch $PREFIX/$path/.gitkeep
done

# Copy default config files
cp $SRC_DIR/conf/master $PREFIX/etc/salt/master.example
cp $SRC_DIR/conf/minion $PREFIX/etc/salt/minion.example
