ls -al
tar Jxvf ${PKG_NAME}-${PKG_VERSION}.txz
cd openkim-models-*
if [[ "$(uname)" == "Darwin" ]]; then
    cmake . -DCMAKE_Fortran_COMPILER=${FC} -DCMAKE_C_COMPILER=${BUILD_PREFIX}/bin/${CC} -DCMAKE_CXX_COMPILER=${BUILD_PREFIX}/bin/${CXX} -DKIM_API_MODEL_DRIVER_INSTALL_PREFIX=${PREFIX}/lib/openkim-models/model-drivers -DKIM_API_PORTABLE_MODEL_INSTALL_PREFIX=${PREFIX}/lib/openkim-models/portable-models -DKIM_API_SIMULATOR_MODEL_INSTALL_PREFIX=${PREFIX}/lib/openkim-models/simulator-models
else
    cmake . -DCMAKE_Fortran_COMPILER=${FC} -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} -DKIM_API_MODEL_DRIVER_INSTALL_PREFIX=${PREFIX}/lib/openkim-models/model-drivers -DKIM_API_PORTABLE_MODEL_INSTALL_PREFIX=${PREFIX}/lib/openkim-models/portable-models -DKIM_API_SIMULATOR_MODEL_INSTALL_PREFIX=${PREFIX}/lib/openkim-models/simulator-models
fi
make install
