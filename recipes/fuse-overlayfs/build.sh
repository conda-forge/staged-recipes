#! /usr/bin/env bash

# Check that version tag is up to date (got out of sync upstream).
grep -qxF "AC_INIT([fuse-overlayfs], [${PKG_VERSION}], [giuseppe@scrivano.org])" configure.ac

./autogen.sh
./configure --prefix="${PREFIX}"
make
make install
