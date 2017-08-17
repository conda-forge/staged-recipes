#!/bin/bash

#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib/:${LD_LIBRARY_PATH}
export INCLUDE_PATH="${PREFIX}/include":${INCLUDE_PATH}
export C_INCLUDE_PATH="${PREFIX}/include":${C_INCLUDE_PATH}
export CPLUS_INCLUDE_PATH="${PREFIX}/include":${CPLUS_INCLUDE_PATH}
export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib

export PKG_CPPFLAGS="-I${PREFIX}/include"
export PKG_LIBS="-L$PREFIX/lib"

$R CMD INSTALL --build .
