#!/usr/bin/env bash
set -eux

if [[ $(uname) == Linux ]]; then
cd $PREFIX
pwd
# tar xvf $SRC_DIR/couchdb/data.tar.gz
tar xvf $SRC_DIR/mozjs/data.tar.gz
ldd usr/lib/libmozjs185.so.1.0.0

elif [[ $(uname) == Darwin ]]; then
APP_DIR=$PREFIX/bin/CouchdbApp
mkdir -p $APP_DIR
cp -rf couchdb/* $APP_DIR

DBBIN_LOCATION=$APP_DIR/Contents/Resources/couchdbx-core/bin/couchdb
# Write launch script and make executable
LAUNCH_SCRIPT=$PREFIX/bin/couchdb
cat <<EOF >$LAUNCH_SCRIPT
#!/bin/bash
$DBBIN_LOCATION "\$@"
EOF
chmod +x $LAUNCH_SCRIPT

JSBIN_LOCATION=$APP_DIR/Contents/Resources/couchdbx-core/bin/couchjs
JS_SCRIPT=$PREFIX/bin/couchjs
cat <<EOF >$JS_SCRIPT
#!/bin/bash
$JSBIN_LOCATION "\$@"
EOF
chmod +x $JS_SCRIPT
fi
