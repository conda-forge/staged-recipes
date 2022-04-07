#! /bin/sh

CPPFLAGS="-DPACKAGE_VERSION=${PKG_VERSION}"
MAKEOPTS="-C ${SRC_DIR} -j ${CPU_COUNT}"

make ${MAKEOPTS}
install -D                 \
    "${SRC_DIR}/dm2smv"    \
    "${SRC_DIR}/tiff2smv"  \
    "${SRC_DIR}/tvips2smv" \
    "${PREFIX}/bin"

make ${MAKEOPTS} tiff2smv.1
install -D                     \
    "${SRC_DIR}/tiff2smv.1"    \
    "${SRC_DIR}/tvips2smv.1"   \
    "${PREFIX}/share/man/man1"
