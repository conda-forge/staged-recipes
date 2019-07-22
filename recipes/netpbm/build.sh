#!/bin/bash

cp ${RECIPE_DIR}/config.mk config.mk
make
TMPDIR=`mktemp -d -u`
make package pkgdir=${TMPDIR}
sed -i 's#/usr/bin/perl#/usr/bin/env perl#g' ${TMPDIR}/bin/*
cp -R ${TMPDIR}/bin ${TMPDIR}/lib ${TMPDIR}/include ${PREFIX}
