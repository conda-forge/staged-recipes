#!/bin/bash

set -ex

export TOP="${EPICS_BASE}/extensions"
export MOTIF_INC="${PREFIX}/include"
export MOTIF_LIB="${PREFIX}/lib"
export X11_INC="${PREFIX}/include"
export X11_LIB="${PREFIX}/lib"

_make="make -j1 V=1 VERBOSE=1 EPICS_BASE=${EPICS_BASE} TOP=${TOP}"

# build
${_make} build

# install
${_make} install
