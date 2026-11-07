#!/bin/bash
set -euxo pipefail
# bundled copies of libraries conda-forge provides (see the patches)
rm -rf libs/qCC_io/extern/shapelib libs/qCC_io/extern/dxflib qCC/extern/QCustomPlot
QDARKSTYLE=$(ls -d ${BUILD_PREFIX}/lib/python3.*/site-packages/qdarkstyle)
EXTRA=""
if [[ "${target_platform}" == osx-* ]]; then
  # Apple's OpenGL framework, not XQuartz's /usr/X11R6 libGL
  EXTRA="-DCMAKE_FIND_FRAMEWORK=FIRST -DCMAKE_IGNORE_PREFIX_PATH=/usr/X11R6"
fi
cmake -S . -B build -G Ninja ${CMAKE_ARGS} ${EXTRA} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DOPTION_DEPLOY_QT=OFF \
  -DOPTION_USE_SYSTEM_SHAPE_LIB=ON \
  -DOPTION_USE_SYSTEM_DXF_LIB=ON \
  -DOPTION_USE_SYSTEM_QCUSTOMPLOT=ON \
  -DQDARKSTYLESHEET_DIR=${QDARKSTYLE} \
  -DCCCORELIB_USE_SYSTEM_NANOFLANN=ON \
  -DPLUGIN_IO_QE57=ON \
  -DPLUGIN_IO_QE57_USE_SYSTEM_LIBE57FORMAT=ON \
  -DCCCORELIB_USE_TBB=ON \
  -DCCCORELIB_USE_CGAL=ON \
  -DEIGEN_ROOT_DIR=$PREFIX/include/eigen3 \
  -DCC_USE_EIGEN=ON \
  -DOPTION_BUILD_CCVIEWER=ON \
  -DPLUGIN_IO_QCORE=ON \
  -DPLUGIN_IO_QADDITIONAL=ON \
  -DPLUGIN_IO_QLAS=ON \
  -DPLUGIN_STANDARD_QM3C2=ON \
  -DPLUGIN_GL_QEDL=ON \
  -DPLUGIN_GL_QSSAO=ON
cmake --build build --parallel ${CPU_COUNT}
cmake --install build
