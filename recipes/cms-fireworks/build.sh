#!/bin/bash
set -e

# copy source and geometry files to install dir
cp -r src "${PREFIX}"
cp -rv data "${PREFIX}"

# set graphics library to link
if [ "$(uname)" == "Linux" ]; then
    cmake_args="-Dgraphicslib=GX11"
else
    cmake_args="-Dgraphicslib=GCocoa"

    # Remove -std=c++14 from build ${CXXFLAGS} and add -std=c++1z
    CXXFLAGS=$(echo "${CXXFLAGS}" | sed -E 's@-std=c\+\+[^ ]+@@g')
    export CXXFLAGS
    export CXXFLAGS="${CXXFLAGS} -std=c++1z"
fi

export BLDDIR=${PWD}/build-dir

mkdir -p ${BLDDIR}

cd ${BLDDIR}

cmake -LAH \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    ${cmake_args} \
    ../src

make -j${CPU_COUNT}

make install

if [ "$(uname)" == "Darwin" ]; then
 cd ${BLDDIR}/lib
 perl -i.bak -pe 's|\.so|.dylib|;' *.rootmap
 rm *.rootmap.bak
fi

cd ${PREFIX}/lib
if [ "$(uname)" == "Linux" ]; then
  ../bin/edmPluginRefresh plugin*.so
else
  ../bin/edmPluginRefresh plugin*.dylib
fi 

cd ${BLDDIR}
cp -v lib/*.pcm "${PREFIX}"/lib 
cp -v lib/*.rootmap "${PREFIX}"/lib 

cd ${PREFIX}
# This should regenerate the precompiled headers for all of the libraries
ROOTIGNOREPREFIX=1 python $PREFIX/etc/dictpch/makepch.py $PREFIX/etc/allDict.cxx.pch -I$PREFIX/include

# Create version.txt expected by cmsShow.exe
echo CMSSW_10_5_0 >src/Fireworks/Core/data/version.txt

# Add the post activate/deactivate scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/activate-fwlite.sh"
cp "${RECIPE_DIR}/activate.csh" "${PREFIX}/etc/conda/activate.d/activate-fwlite.csh"
cp "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/activate-fwlite.fish"

mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/deactivate-fwlite.sh"
cp "${RECIPE_DIR}/deactivate.csh" "${PREFIX}/etc/conda/deactivate.d/deactivate-fwlite.csh"
cp "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/deactivate-fwlite.fish"

