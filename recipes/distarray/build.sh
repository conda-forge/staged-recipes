export CFLAGS="-Wall -g -m64 -pipe -O2  -fPIC $CFLAGS"
export CXXLAGS="${CFLAGS}"
export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib"

python setup.py install
