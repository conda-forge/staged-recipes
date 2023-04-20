#!/usr/bin/env bash
set -e
system=$(uname -s)

case $system in
    "Linux" )
		${CXX} test.cpp ${CFLAGS} ${LDFLAGS} -o test
		./test
		;;
    "Darwin" )
        export DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH:${PREFIX}/lib
    	${CXX} test.cpp ${CFLAGS} ${LDFLAGS} -o test
    	./test
    	;;
esac
