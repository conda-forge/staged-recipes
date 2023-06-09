#!/bin/bash

# adapted from upstream: https://github.com/SEATStandards/ncvis/blob/main/build.sh

set -euxo pipefail

# set the install prefix
PREFIX="${PREFIX}"

# get the wxwidgets build flags
WXFLAGS=`wx-config --cxxflags --libs --cppflags`

# get the netCDF build flags
NCFLAGS=`nc-config --cflags --libs`

# infer the RPATH needed for dynamic linking to wxwidgets
RPATH=`wx-config --prefix`/lib

# build the executable
cd src && $CXX -std=c++11 -fpermissive -Wl,-rpath,${RPATH} -o ${PREFIX}/bin/ncvis ncvis.cpp kdtree.cpp wxNcVisFrame.cpp wxNcVisOptionsDialog.cpp wxNcVisExportDialog.cpp wxImagePanel.cpp GridDataSampler.cpp ColorMap.cpp netcdf.cpp ncvalues.cpp Announce.cpp TimeObj.cpp ShpFile.cpp schrift.cpp lodepng.cpp ${WXFLAGS} ${NCFLAGS}

# copy the resoruces folder to $PREFIX/share
cd .. && mkdir ${PREFIX}/share/ncvis
cp -r resources ${PREFIX}/share/ncvis/
