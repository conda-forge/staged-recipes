#!/bin/sh

set -x

# error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
curl -L https://github.com/OpenModelica/OMCompiler-3rdParty/pull/89.patch | patch -p1 -d OMCompiler/3rdParty

# https://github.com/OpenModelica/OpenModelica/issues/15337
# add_subdirectory given source "testsuite" which is not an existing
sed -i "/omc_add_subdirectory(testsuite)/d" CMakeLists.txt
# delete 5 last lines to drop tests
head -n -5 OMCompiler/SimulationRuntime/c/CMakeLists.txt > CMakeLists.txt.new && mv CMakeLists.txt.new OMCompiler/SimulationRuntime/c/CMakeLists.txt

cmake ${CMAKE_ARGS} -G "Ninja" -LAH \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DOM_ENABLE_GUI_CLIENTS=ON -DOM_QT_MAJOR_VERSION=5 -DOM_OMEDIT_ENABLE_QTWEBENGINE=ON \
  -DOM_OMC_ENABLE_FORTRAN=ON -DOM_OMC_ENABLE_OPTIMIZATION=ON -DOM_OMC_ENABLE_MOO=ON \
  -DOM_USE_CCACHE=OFF \
  -DBLA_VENDOR=Generic \
  -B build -S .
cmake --build build --target install --parallel ${CPU_COUNT}
