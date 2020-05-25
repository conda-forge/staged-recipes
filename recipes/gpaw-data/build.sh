#!/bin/bash
mkdir -p ${PREFIX}/share/gpaw
for f in $(ls *.gz); do cp $f ${PREFIX}/share/gpaw; done
