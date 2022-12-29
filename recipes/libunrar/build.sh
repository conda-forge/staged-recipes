set -ex

DEST_DIR="${PREFIX}"

make all
make install-lib install-unrar

# Include header files
mkdir -p "${DEST_DIR}/include/unrar"
cp *.hpp "${DEST_DIR}/include/unrar"

# CFEP-18
rm "${DEST_DIR}/lib/libunrar.a"
