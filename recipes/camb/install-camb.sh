#!/bin/bash

BINDIR=${PREFIX}/bin
SHAREDIR=${PREFIX}/share/camb

mkdir -p ${BINDIR} ${SHAREDIR} || true
cp ${SRC_DIR}/camb ${BINDIR}/
cp ${SRC_DIR}/HighLExtrapTemplate_lenspotentialCls.dat ${SHAREDIR}/
