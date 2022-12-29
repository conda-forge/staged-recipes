set -ex

DESTDIR="${PREFIX}"

make lib
make install-lib

make unrar
make install-unrar

# Include header files
mkdir -p "${PREFIX}/include/unrar"
cp *.hpp "${PREFIX}/include/unrar"

# CFEP-18
rm "${PREFIX}/lib/libunrar.a"
