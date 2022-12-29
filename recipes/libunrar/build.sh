set -ex

DEST_DIR="${PREFIX}"

make lib
make install-lib

make unrar
make install-unrar

# Include header files
mkdir -p "${DEST_DIR}/include/unrar"
cp *.hpp "${DEST_DIR}/include/unrar"

# CFEP-18
rm "${DEST_DIR}/lib/libunrar.a"
