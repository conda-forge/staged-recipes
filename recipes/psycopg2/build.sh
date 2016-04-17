#!/bin/bash

export LDFLAGS="${LDFLAGS} -L$PREFIX/lib -lssl"

$PYTHON setup.py install

if [[ `uname` == 'Darwin' ]]; then
     PG_LIB=$(pg_config --libdir)
     for LIBRARY in `find ${SP_DIR}/${PKG_NAME} -name "*.so"`;
     do
        install_name_tool -change libssl.1.0.0.dylib @rpath/libssl.1.0.0.dylib $LIBRARY
        install_name_tool -change libcrypto.1.0.0.dylib @rpath/libcrypto.1.0.0.dylib $LIBRARY
     done
fi
