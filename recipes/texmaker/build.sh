#!/bin/bash

qmake -set prefix $PREFIX

qmake \
    PREFIX=$PREFIX \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    texmaker.pro
make -j$CPU_COUNT
bash -c "qmake -set prefix $PREFIX; make install PREFIX=$PREFIX; exit 0" || true
