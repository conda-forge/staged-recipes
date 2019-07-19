#!/bin/bash

cp config.mk.in config.mk
envsubst '${PREFIX}' < ${RECIPE_DIR}/config.template >> config.mk
make
TMPDIR=`mktemp -d -u`
make package pkgdir=${TMPDIR}
sed -i s#/usr/bin/perl#/opt/anaconda1anaconda2anaconda3/bin/perl#g ${TMPDIR}/bin/*
cp -R ${TMPDIR}/bin ${TMPDIR}/lib ${TMPDIR}/include ${TMPDIR}/man ${PREFIX}
