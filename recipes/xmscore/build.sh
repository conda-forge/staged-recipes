#!/bin/bash
cp ${RECIPE_DIR}/condabuildinfo.cmake .

mkdir -p build
cd build

${BUILD_PREFIX}/bin/cmake \
     -DCMAKE_INSTALL_PREFIX=${PREFIX} \
     -DCMAKE_BUILD_TYPE=Release \
     -DIS_CONDA_BUILD=True \
     -DCONDA_PREFIX=${CONDA_PREFIX} \
     -DIS_PYTHON_BUILD=True \
     -DPYTHON_TARGET_VERSION=${PY_VER} \
     -DPYTHON_SITE_PACKAGES=${SP_DIR} \
     -DBOOST_ROOT=${BUILD_PREFIX} \
     -DXMS_VERSION="${XMS_VERSION}" ${SRC_DIR}


make -j${CPU_COUNT}
make install

cd ..
cp ./build/_xms*.so ./_package/xms/core/

${PYTHON} -m pip install ./_package --no-deps --ignore-installed -vvv
