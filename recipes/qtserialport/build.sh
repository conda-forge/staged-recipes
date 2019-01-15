#!/bin/bash

[[ -d build ]] || mkdir build
cd build/

# Need to specify these QMAKE variables because of build environment residue
# in qt mkspecs referencing "qt_1548879054661"
# Report: https://github.com/conda-forge/qtlocation-feedstock/pull/3#issuecomment-466278804
# Fix PR: https://github.com/conda-forge/qt-feedstock/pull/97
qmake \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    ..

make -j$CPU_COUNT
make check
make install
