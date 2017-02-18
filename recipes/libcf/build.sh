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

./configure --prefix=${PREFIX}
${PYTHON} setup.py install
if [ `uname` == Darwin ]; then install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python @rpath/libpython2.7.dylib ${SP_DIR}/pycf/*.so ; fi
