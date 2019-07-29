#!/bin/bash
cp ${RECIPE_DIR}/condabuildinfo.cmake .

mkdir -p build
cd build
${BUILD_PREFIX}/bin/cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DXMS_VERSION=${PKG_VERSION} -DCMAKE_BUILD_TYPE=Release -DPYTHON_TARGET_VERSION=${PY_VER} -DIS_CONDA_BUILD=True -DIS_PYTHON_BUILD=True -DCONDA_PREFIX=${CONDA_PREFIX} -DPYTHON_SITE_PACKAGES=${SP_DIR} -DBOOST_ROOT=${BUILD_PREFIX} -DXMS_VERSION="${XMS_VERSION}" ..

make -j${CPU_COUNT}

make install

echo "*********************************************"
ls -lah
echo "${SP_DIR}"
echo "*********************************************"

mkdir -p "${SP_DIR}"
cp *.so ${SP_DIR}
