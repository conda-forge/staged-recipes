export CFLAGS="-Wall -g -m64 -pipe -O2  -fPIC ${CFLAGS}"
export CXXLAGS="${CFLAGS} ${CXXFLAGS}"
export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

if [ `uname` == Linux ]; then
    MAKEFILE=libdrs_Makefile.Linux.gfortran
    echo "Linux  "${PREFIX}
else
    MAKEFILE=libdrs_Makefile.Mac.fwrap.gfortran
    echo "Mac  "${PREFIX}
fi
cd lib
if [ `uname` == Linux ]; then
    sed "s#libdrs#libdrsfortran#g;" ${MAKEFILE}.in > ${MAKEFILE}.tmp
    sed "s#@cdat_EXTERNALS@#${PREFIX}#g;" ${MAKEFILE}.tmp > ${MAKEFILE}
else
    sed "s#@cdat_EXTERNALS@#${PREFIX}#g;" ${MAKEFILE}.in > ${MAKEFILE}
fi
make  -f ${MAKEFILE}
make -f ${MAKEFILE} install
# No make check or make test
