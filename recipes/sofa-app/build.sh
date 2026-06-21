#!/bin/sh

set -ex

if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# SceneChecking application
# ----------

# We have to manually set the Rpath for other SOFA libs to the lib/ directory using
# the CMAKE_INSTALL_RPATH cmake variable, as SOFA CMakeLists are not designed 
# initially for a per-component compilation & installation
cmake ${CMAKE_ARGS} \
  -B build-scene-checking \
  -S ./applications/projects/SceneChecking/ \
  -G Ninja \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DSCENECHECKING_BUILD_TESTS=OFF \
  -DCMAKE_INSTALL_RPATH:PATH=${PREFIX}/lib

# build
cmake --build build-scene-checking --parallel ${CPU_COUNT}

# install
cmake --install build-scene-checking

# runSofa application
# ----------

# We have to manually set the Rpath for other SOFA libs to the lib/ directory using
# the CMAKE_INSTALL_RPATH cmake variable, as SOFA CMakeLists are not designed 
# initially for a per-component compilation & installation
cmake ${CMAKE_ARGS} \
  -B build-sofa-app \
  -S ./applications/projects/runSofa/ \
  -G Ninja \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_RPATH:PATH=${PREFIX}/lib

# build
cmake --build build-sofa-app --parallel ${CPU_COUNT}

# install
cmake --install build-sofa-app

# For macOS, we have to provide this additionnal script as an hotfix
# for users who would like to load SofaPython3 plugin in runSofa
# application.
# See hotfix-sofa-run-macos.sh for more details.
if [[ $target_platform == osx* ]] ; then
    cp "${RECIPE_DIR}/hotfix-sofa-run-macos.sh" "${PREFIX}/bin/runSofa_with_python"
fi

# runSofa app requires some data ressources, which will
# be included in this package
# ----------

cmake ${CMAKE_ARGS} \
  -B build-sofa-examples \
  -S ./examples/ \
  -G Ninja \
  -DCMAKE_BUILD_TYPE:STRING=Release

# build
cmake --build build-sofa-examples --parallel ${CPU_COUNT}

# install
cmake --install build-sofa-examples