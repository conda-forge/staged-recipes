#!/bin/bash

set -x

## because qmake.
ln -s ${CXX} ${PREFIX}/bin/g++ || true
ln -s ${CXX} ${PREFIX}/bin/gcc || true

## should make this a proper patch instead ...
export "CURRENT_R_VERSION=$(Rscript -e 'cat(substr(paste(R.Version()[c("major", "minor")], collapse = "."),1,3))')"
sed -i "s/^CURRENT_R_VERSION.*/CURRENT_R_VERSION = ${CURRENT_R_VERSION}/g" JASP.pri
sed -i "s:/usr/:${PREFIX}/:g" JASP-Desktop/gui/preferencesmodel.cpp
sed -i "s:/usr/:${PREFIX}/:g" JASP-Desktop/JASP-Desktop.pro
sed -i "s:/usr/:${PREFIX}/:g" JASP.pri
sed -i "s:/usr/:${PREFIX}/:g" JASP-Desktop/utilities/appdirs.cpp
sed -i "s:/usr/:${PREFIX}/:g" JASP-Desktop/JASP-Desktop.pro

mkdir build
cd build

export QMAKE_CXXFLAGS+=${CXXFLAGS}
export QMAKE_CFLAGS+=${CFLAGS}
export QMAKE_LFLAGS+=${LDFLAGS}
export PATH=${PWD}/bin:${PATH}
export PATH=${PREFIX}/bin:${PATH}
export R_HOME=${PREFIX}/lib/R
export _R_HOME=${PREFIX}/lib/R
export JASP_R_HOME=${PREFIX}/lib/R
export CURRENT_R_VERSION=${CURRENT_R_VERSION}

mkdir -p ${PREFIX}/lib/JASP

## don't know if there is a better way than listing out all the library and
## include directories here, but qmake doesn't seem to find them otherwise
qmake \
    PREFIX=$PREFIX \
    INSTALLPATH=${PREFIX}/lib/JASP/ \
    CONFIG+=release \
    JASP_R_HOME=${PREFIX}/lib/R \
    R_HOME=${PREFIX}/lib/R \
    _R_HOME=${PREFIX}/lib/R \
    JASP_R_HOME=${PREFIX}/lib/R \
    CURRENT_R_VERSION=${CURRENT_R_VERSION} \
    QMAKE_CC=$(basename ${CC}) \
    QMAKE_CXX=$(basename ${CXX}) \
    QMAKE_LINK=$(basename ${CXX}) \
    QMAKE_RANLIB=$(basename ${RANLIB}) \
    QMAKE_OBJDUMP=$(basename ${OBJDUMP}) \
    QMAKE_STRIP=$(basename ${STRIP}) \
    QMAKE_AR="$(basename ${AR}) cqs" \
    "QMAKE_LIBDIR+=${PREFIX}/lib" \
    "QMAKE_LIBDIR+=${BUILD_PREFIX}x86_64-conda-linux-gnu/sysroot/usr/lib" \
    "QMAKE_LIBDIR+=${PREFIX}/lib/R/lib" \
    "QMAKE_LIBDIR+=${PREFIX}/lib/R/library/Rcpp/libs" \
    "QMAKE_LIBDIR+=${PREFIX}/lib/R/library/RInside/lib" \
    "INCLUDEPATH+=${PREFIX}/include" \
    "INCLUDEPATH+=${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include" \
    "INCLUDEPATH+=${PREFIX}/lib/R/include" \
    "INCLUDEPATH+=${PREFIX}/lib/R/library/Rcpp/include" \
    "INCLUDEPATH+=${PREFIX}/lib/R/library/RInside/include" \
    "INCLUDEPATH+=${PREFIX}/include/boost" \
    ../JASP.pro

make -j$CPU_COUNT || make -j$CPU_COUNT || make

## make install
mkdir -p ${PREFIX}/lib/JASP
rm -rf  JASP-Common JASP-Desktop JASP-Engine JASP-R-Interface
rsync -a --ignore-existing ./ ${PREFIX}/lib/JASP/
ln -sfr ${PREFIX}/lib/JASP/jasp ${PREFIX}/bin/

## cleanup qmake nonsense
rm ${PREFIX}/bin/g++ || true
rm ${PREFIX}/bin/gcc || true

## install activate / deactivate scripts
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
