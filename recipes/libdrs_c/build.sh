export CFLAGS="-Wall -g -m64 -pipe -O2  -fPIC ${CFLAGS}"
export CXXLAGS="${CFLAGS} ${CXXLAGS}"
export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

if [ `uname` == Linux ]; then
    MAKEFILE=libdrs_Makefile.Linux.gfortran
    echo "Linux  "${PREFIX}
else
    MAKEFILE=libdrs_Makefile.Mac.gfortran
    echo "Mac  "${PREFIX}
fi

cd lib
sed "s#@cdat_EXTERNALS@#${PREFIX}#g;" ${MAKEFILE}.in > Makefile
make  
make  install
