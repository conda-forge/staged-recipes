#!/bin/bash

set -ex

cd build/linux && ./make_gnu.sh
cp bin/elmfire_$ELMFIRE_VERSION $PREFIX/bin/elmfire
