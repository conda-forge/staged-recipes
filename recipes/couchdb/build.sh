#!/usr/bin/env bash
set -eux

if [[ $(uname) == Linux ]]; then
cd $PREFIX
tar --strip-components=2 -xvf $SRC_DIR/mozjs/data.tar.gz
tar --strip-components=2 -xvf $SRC_DIR/mozjsdev/data.tar.gz
chmod +x lib/libmozjs185.so.1.0.0
patchelf --set-rpath '$ORIGIN' lib/libmozjs185.so.1.0.0

# find .
# ldd lib/libmozjs185.so
# readelf -d lib/libmozjs185.so

cd $SRC_DIR/couchdb
sed -i "s|-DXP_UNIX -I/usr/include/js -I/usr/local/include/js|-DXP_UNIX -I$PREFIX/include/js|g" src/couch/rebar.config.script
sed -i "s|-L/usr/local/lib -lmozjs185 -lm|-L$PREFIX/lib -lmozjs185 -lm -Wl,-rpath,$PREFIX/lib|g" src/couch/rebar.config.script
export ERL_CFLAGS="-I$PREFIX/include -I$PREFIX/include/js -I$PREFIX/lib/erlang/usr/include"
export ERL_LDFLAGS="-L$PREFIX/lib"
./configure
make release

install -dm755 $PREFIX/lib
cp -r rel/couchdb $PREFIX/lib/couchdb
# find $PREFIX/lib/couchdb

CORE_ROOT=$PREFIX/lib/couchdb

elif [[ $(uname) == Darwin ]]; then
APP_DIR=$PREFIX/bin/CouchdbApp
mkdir -p $APP_DIR
cp -rf couchdb/* $APP_DIR

CORE_ROOT=$APP_DIR/Contents/Resources/couchdbx-core
fi

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
