#!/bin/sh

set -ex

mkdir build
cd build

export SOFA_PLUGINS_DIR=${SRC_DIR}/plugins
touch ${SOFA_PLUGINS_DIR}/CMakeLists.txt
echo 'sofa_add_subdirectory(plugin SoftRobots SoftRobots)' >> ${SOFA_PLUGINS_DIR}/CMakeLists.txt
echo 'sofa_add_subdirectory(plugin plugin.Cosserat CosseratPlugin)' >> ${SOFA_PLUGINS_DIR}/CMakeLists.txt
echo 'sofa_add_subdirectory(plugin BeamAdapter BeamAdapter)' >> ${SOFA_PLUGINS_DIR}/CMakeLists.txt
echo 'sofa_add_subdirectory(plugin STLIB STLIB)' >> ${SOFA_PLUGINS_DIR}/CMakeLists.txt
echo 'sofa_add_subdirectory(plugin ModelOrderReduction ModelOrderReduction)' >> ${SOFA_PLUGINS_DIR}/CMakeLists.txt
# echo 'sofa_add_subdirectory(plugin SofaPython3 SofaPython3)' >> ${SOFA_PLUGINS_DIR}/CMakeLists.txt

cmake ${CMAKE_ARGS} .. \
   -DSOFA_EXTERNAL_DIRECTORIES=${SRC_DIR}/plugins \
   -DPLUGIN_SOFTROBOTS=ON \
   -DPLUGIN_COSSERATPLUGIN=ON \
   -DPLUGIN_BEAMADAPTER=ON \
   -DPLUGIN_STLIB=ON \
   -DPLUGIN_MODELORDERREDUCTION=ON \
#    -DPLUGIN_SOFAPYTHON3=ON \

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# install 
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

# test
ctest --parallel ${CPU_COUNT} --verbose