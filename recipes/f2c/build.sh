#!/bin/bash

# Copy Makefile from the source directory

cp ${RECIPE_DIR}/Makefile .

export LDFLAGS="-Wl,-rpath,${PREFIX}/lib"

case "$(uname)" in
Linux)

    export CC=${PREFIX}/bin/gcc
    
    make hadd
    
    make all

;;

Darwin)

    export CC=clang
    
    make hadd
    
    make all
;;
*)
echo "Unsupported"
exit 1
;;
esac

make install libdir=${PREFIX}/lib \
  includedir="${PREFIX}/include/f2c" \
  LIBDIR=${PREFIX}/lib \
  INCDIR="${PREFIX}/include/f2c"

# Some programs need f2c.h to be in ${PREFIX/include, not in ${PREFIX}/include/f2c
cp ${PREFIX}/include/f2c/* ${PREFIX}/include

# Now copy a small "Hello world" program into the share folder so
# we can test the installation
mkdir -p ${PREFIX}/share/f2c

cp ${RECIPE_DIR}/test_main.c ${PREFIX}/share/f2c
