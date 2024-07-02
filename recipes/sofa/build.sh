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

# We install to a temp directory to avoid duplicate compilation for libsofa and
# sofa-devel. This is inspired from:
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
  -DPLUGIN_SOFAVALIDATION=OFF \
  -DPLUGIN_SOFA_GUI_QT=OFF \
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

# For macOS, we have to provide this additionnal script as an hotfix
# for users who would like to load SofaPython3 plugin in runSofa
# application.
# See scripts/hotfix-sofa-run-macos.sh for more details.
if [[ $target_platform == osx* ]] ; then
    cp "${RECIPE_DIR}/scripts/hotfix-sofa-run-macos.sh" "${PREFIX}/bin/runSofa_with_python"
fi
