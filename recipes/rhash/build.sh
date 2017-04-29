#!/bin/bash

make ADDCFLAGS="${CFLAGS}" ADDLDFLAGS="${LDFLAGS}" build-shared

make PREFIX="" DESTDIR=${PREFIX} install-shared

make -C librhash PREFIX="" DESTDIR=${PREFIX} install-headers install-lib-shared install-lib-static

cd tests
./test_rhash.sh
