#!/bin/bash
cd src
make

mkdir -p ${PREFIX}/bin
cp kg4vasp.x ${PREFIX}/bin
