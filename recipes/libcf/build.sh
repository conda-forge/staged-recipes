export CFLAGS="-Wall -g -m64 -pipe -O2  -fPIC ${CFLAGS}"
export CXXLAGS="${CFLAGS} ${CXXLAGS}"
export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"
export LFLAGS="-fPIC ${LFLAGS}"

if [ "$(uname)" == "Darwin" ]; then
    export CXXFLAGS="${CXXFLAGS} -fno-common"
    export MACOSX_DEPLOYMENT_TARGET=$(sw_vers -productVersion | sed -E "s/([0-9]+\.[0-9]+).*/\1/")
    export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib
    export LDFLAGS="${LDFLAGS} -lpython" 

fi

CONDA_LST=`conda list`
if [[ ${CONDA_LST}'y' == *'openmpi'* ]]; then
    export CC=mpicc
    export CXX=mpicxx
    export LC_RPATH="${PREFIX}/lib"
    export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib
fi
./configure --prefix=${PREFIX}
${PYTHON} setup.py install
