#!/bin/sh
# setup env for tests
cd "${SRC_DIR}/tests"
export PATH="${PREFIX}/bin:${PATH}"

#UNAME="$(uname)"
#if [ "${UNAME}" == "Darwin" ]; then
#  export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH}"
#else
#  export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
#fi

# run tests
test -f ${PREFIX}/lib/libpyne*
test -f ${PREFIX}/include/pyne/pyne.h
nosetests
