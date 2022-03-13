#!/usr/bin/env bash
set -eux

APP_DIR=$PREFIX/bin/CouchdbApp
LAUNCH_SCRIPT=$PREFIX/bin/couchdb

mkdir -p $APP_DIR

if [[ $(uname) == Linux ]]; then
    cd $APP_DIR
    tar xvf $SRC_DIR/couchdb/data.tar.gz
    tar xvf $SRC_DIR/mozjs/data.tar.gz
    BIN_LOCATION=$PREFIX/opt/couchdb/bin/couchdb
elif [[ $(uname) == Darwin ]]; then
    find couchdb
    cp -rf couchdb/* $APP_DIR
    BIN_LOCATION=$APP_DIR/Contents/Resources/couchdbx-core/bin/couchdb
fi

# Write launch script and make executable
cat <<EOF >$LAUNCH_SCRIPT
#!/bin/bash
$BIN_LOCATION "\$@"
EOF
chmod +x $LAUNCH_SCRIPT