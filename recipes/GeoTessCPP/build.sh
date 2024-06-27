#!/usr/bin/env bash

set -e

make all CC=${CC}

# copy dynamic libraries into standard location
cp lib/* $PREFIX/lib/

# copy headers into standard location
mkdir -p $PREFIX/include/geotesscpp
cp GeoTessCPP/include/* $PREFIX/include/geotesscpp
cp GeoTessAmplitudeCPP/include/* $PREFIX/include/geotesscpp

