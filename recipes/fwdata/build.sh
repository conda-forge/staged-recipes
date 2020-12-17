#!/bin/bash
set -e

# checkout and find cmaketools
git clone https://github.com/gartung/cmaketools
CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}:$PWD/cmaketools

# set graphics library to link
if [ "$(uname)" == "Linux" ]; then
    cmake_args="-DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release"
    export CXXFLAGS="${CXXFLAGS}"
else
    cmake_args="-DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}" 

    # Remove -std=c++14 from build ${CXXFLAGS} and use cmake to set std flags
    CXXFLAGS=$(echo "${CXXFLAGS}" | sed -E 's@-std=c\+\+[^ ]+@@g')
    export CXXFLAGS
fi

export BLDDIR=${PWD}/build-dir
mkdir -p ${BLDDIR}
cp -r src ${BLDDIR}
cd ${BLDDIR}

cmake -LAH \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    ${cmake_args} \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.14 \
    ../src

make -j${CPU_COUNT}

make install

if [ "$(uname)" == "Darwin" ]; then
    cd ${BLDDIR}/lib
    perl -i -pe "s|\.so|${SHLIB_EXT}|;" *.rootmap
fi

cd ${BLDDIR}
cp -v lib/*.pcm "${PREFIX}"/lib
cp -v lib/*.rootmap "${PREFIX}"/lib

# Add the post activate/deactivate scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
sed  "s/CMSSW_XX_YY_ZZ/${CMSSW_VERSION}/g" "${RECIPE_DIR}/activate.sh" > "${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh"
sed  "s/CMSSW_XX_YY_ZZ/${CMSSW_VERSION}/g" "${RECIPE_DIR}/activate.csh" > "${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.csh"
sed  "s/CMSSW_XX_YY_ZZ/${CMSSW_VERSION}/g" "${RECIPE_DIR}/activate.fish" > "${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.fish"

mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh"
cp "${RECIPE_DIR}/deactivate.csh" "${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.csh"
cp "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.fish"
