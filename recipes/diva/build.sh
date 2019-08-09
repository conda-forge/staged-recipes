#!/bin/bash

pushd DIVA3D/src/Fortran/
make
popd

cp -r DIVA3D/divastripped ${PREFIX}/bin/divastripped
