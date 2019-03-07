#!/bin/bash

./configure --prefix=${PREFIX}             \
            --enable-opie                  \
            --enable-digest                \
            --enable-ntlm                  \
            --enable-debug                 \
            --with-ssl=openssl             \
            --with-openssl=${PREFIX}       \
	    --with-libssl-prefix=${PREFIX} \
            --with-zlib=${PREFIX}          \
            --with-metalink                \
            --with-cares                   \
            --with-libpsl                  \
	    CC=${CC}
make
make check || (cat tests/test-suite.log && exit 1)
make install
