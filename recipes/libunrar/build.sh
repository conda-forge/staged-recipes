set -ex

make lib
DESTDIR="${PREFIX}" make install-lib

make unrar
DESTDIR="${PREFIX}" make install-unrar

# Include header files
mkdir -p "${PREFIX}/include/unrar"
cp *.hpp "${PREFIX}/include/unrar"

# CFEP-18
rm "${PREFIX}/lib/libunrar.a"
