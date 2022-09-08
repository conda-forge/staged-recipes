#!/usr/bin/env bash

mkdir -p "${PREFIX}/lib/cosmosis-standard-library"
cp -a * "${PREFIX}/lib/cosmosis-standard-library"
cd "${PREFIX}/lib/cosmosis-standard-library"

function DoSource() { source cosmosis-configure ; } ; DoSource

export USER_CXXFLAGS="$USER_CXXFLAGS -I${PREFIX}/include"
export USER_LDFLAGS="$USER_LDFLAGS -L${PREFIX}/lib"

# This next line is a hack to workaround cosmosis makefiles
export GSL_LIB="$GSL_LIB -L${PREFIX}/lib"
export GSL_INC="$GSL_INC -I${PREFIX}/include"
export LAPACK_LINK="$LAPACK_LINK -lblas"
export CFITSIO_LIB="${PREFIX}/lib"
export CFITSIO_INC="${PREFIX}/include"

make

cp "${COSMOSIS_SRC_DIR}/datablock/libcosmosis.so" "${PREFIX}/lib"
find . -name '.a' 

#find . -print0 -name '.a' | xargs -0 rm 
#find . -print0 -name '.o' | xargs -0 rm 


