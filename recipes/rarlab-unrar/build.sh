set -ex

DEST_DIR="${PREFIX}"

make all
make install-lib install-unrar

# CFEP-18
rm "${DEST_DIR}/lib/libunrar.a"
