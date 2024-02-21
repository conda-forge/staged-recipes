#!/bin/sh

set -ex

if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

rm -rf build

mkdir build
cd build

# We install to a temp directory to avoid duplicate compilation for libsofa-core and 
# libsofa-core-devel. This is inspired from:
# https://github.com/conda-forge/boost-feedstock/blob/main/recipe/meta.yaml
mkdir temp_prefix

cmake ${CMAKE_ARGS} \
  -B . \
  -S .. \
  -DCMAKE_INSTALL_PREFIX:PATH=temp_prefix/ \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DSOFA_ENABLE_LEGACY_HEADERS:BOOL=OFF \
  -DAPPLICATION_SOFAPHYSICSAPI=OFF \
  -DSOFA_BUILD_SCENECREATOR=OFF \
  -DSOFA_BUILD_TESTS=OFF \
  -DSOFA_FLOATING_POINT_TYPE=double \
  -DPLUGIN_CIMGPLUGIN=OFF \
  -DPLUGIN_SOFAMATRIX=OFF \
  -DPLUGIN_SOFADENSESOLVER=OFF \
  -DPLUGIN_SOFAEXPORTER=OFF \
  -DPLUGIN_SOFAHAPTICS=OFF \
  -DPLUGIN_SOFAOPENGLVISUAL=OFF \
  -DPLUGIN_SOFAPRECONDITIONER=OFF \
  -DPLUGIN_SOFAVALIDATION=OFF \
  -DPLUGIN_SOFA_GUI_QT=OFF \
  -DSOFA_GUI_QT_ENABLE_QGLVIEWER=OFF \
  -DSOFAGUI_QT=OFF \
  -DSOFA_GUI_QT_ENABLE_QTVIEWER=OFF \
  -DSOFAGUI_QGLVIEWER=OFF \
  -DSOFAGUI_QTVIEWER=OFF \
  -DSOFA_NO_OPENGL=ON \
  -DSOFA_WITH_OPENGL=OFF \
  -DPLUGIN_MULTITHREADING=ON \
  -DAPPLICATION_RUNSOFA=OFF \
  -DPLUGIN_ARTICULATEDSYSTEMPLUGIN=OFF \
  -DSOFA_ALLOW_FETCH_DEPENDENCIES=OFF

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done