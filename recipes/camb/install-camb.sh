#!/bin/bash

BINDIR=${PREFIX}/bin

mkdir -p ${BINDIR} || true
cp ${SRC_DIR}/camb ${BINDIR}/
