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

CORE_ROOT=$APP_DIR/Contents/Resources/couchdbx-core
# Write launch script and make executable
LAUNCH_SCRIPT=$PREFIX/bin/couchdb
cat <<EOF >$LAUNCH_SCRIPT
#!/bin/bash
cd $CORE_ROOT
./bin/couchdb "\$@"
EOF
chmod +x $LAUNCH_SCRIPT

JS_SCRIPT=$PREFIX/bin/couchjs
cat <<EOF >$JS_SCRIPT
#!/bin/bash
cd $CORE_ROOT
./bin/couchjs "\$@"
EOF
chmod +x $JS_SCRIPT
fi
