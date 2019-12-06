#!/bin/bash

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}-${PKG_NAME}.sh" .
    sed -i.bak "s|@CHOST@|$CHOST|g" ${CHANGE}-${PKG_NAME}.sh 
    sed -i.bak "s|@WINSDK_VERSION@|$WINSDK_VERSION|g" ${CHANGE}-${PKG_NAME}.sh 
    sed -i.bak "s|@MSVC_HEADERS_VERSION@|$MSVC_HEADERS_VERSION|g" ${CHANGE}-${PKG_NAME}.sh 
    cp ${CHANGE}-${PKG_NAME}.sh ${PREFIX}/etc/conda/${CHANGE}.d/${CHANGE}-${PKG_NAME}.sh
done

if [[ "$PKG_NAME" == "clang_win-64" ]]; then
  mkdir -p $PREFIX/bin
  pushd ${PREFIX}/bin
    ln -sf $(which clang) ${CHOST}-clang
    ln -sf $(which clang++) ${CHOST}-clang++
    ln -sf $(which llvm-as) ${CHOST}-as
    ln -sf $(which llvm-lib) lib
  popd
fi
