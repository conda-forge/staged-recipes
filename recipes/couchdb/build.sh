#!/usr/bin/env bash
set -eux

if [[ $(uname) == Darwin ]]; then
    sed -i '' "s|-I/usr/local/opt/icu4c/include -I/opt/homebrew/opt/icu4c/include|-I$PREFIX/include|g" src/couch/rebar.config.script
    sed -i '' "s|-L/usr/local/opt/icu4c/lib -L/opt/homebrew/opt/icu4c/lib|-L$PREFIX/lib|g" src/couch/rebar.config.script
fi
export CFLAGS="-I$PREFIX/include -I$PREFIX/include/mozjs-91 -I$PREFIX/lib/erlang/usr/include"
export LDFLAGS="-L$PREFIX/lib"
export ERL_CFLAGS="$CFLAGS"
export ERL_LDFLAGS="$LDFLAGS"
./configure --erlang-md5 --spidermonkey-version 91
make release

install -dm755 $PREFIX/lib
cp -r rel/couchdb $PREFIX/lib/couchdb

CORE_ROOT=$PREFIX/lib/couchdb

ln -sf $CORE_ROOT/bin/couchdb $PREFIX/bin/couchdb
ln -sf $CORE_ROOT/bin/couchjs $PREFIX/bin/couchjs
