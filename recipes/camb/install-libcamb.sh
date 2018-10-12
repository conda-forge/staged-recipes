#!/bin/bash

LIBDIR=${PREFIX}/lib
SHAREDIR=${PREFIX}/share/camb

mkdir -p ${LIBDIR} ${SHAREDIR} || true
cp ${SRC_DIR}/Release/libcamb_recfast.a ${LIBDIR}/
cp ${SRC_DIR}/HighLExtrapTemplate_lenspotentialCls.dat ${SHAREDIR}/
# cp ${SRC_DIR}/Release/camblib.so ${LIBDIR}/
