export CFLAGS="-Wall -g -m64 -pipe -O2  -fPIC ${CFLAGS}"
export CXXLAGS="${CFLAGS} ${CXXLAGS}"
export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"
export LFLAGS="-fPIC ${LFLAGS}"


./configure --prefix=${PREFIX}
${PYTHON} setup.py install
if [ `uname` == Darwin ]; then install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python @rpath/libpython2.7.dylib ${SP_DIR}/pycf/*.so ; fi
