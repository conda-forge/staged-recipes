#!/bin/bash

# Needed to ensure our OpenSSL and
# not the system one is used on OS X.
export LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="-I${PREFIX}/include ${CFLAGS}"
export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

# Set the fallback library environment variable.
if [[ `uname` == 'Darwin' ]];
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi


chmod +x ./autogen.sh

./autogen.sh
./configure --prefix="${PREFIX}"
make

#
# Seems to hang on Mac builds. So have commented it for now.
#
#eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check

make install

# Remove Python script to avoid confusion and a Python dependency.
rm -fv "${PREFIX}/bin/event_rpcgen.py"
