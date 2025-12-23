#!/bin/sh

set -ex

if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# SceneChecking application
# ----------
rm -rf build-scene-checking

mkdir build-scene-checking
cd build-scene-checking

# We have to manually set the Rpath for other SOFA libs to the lib/ directory using
# the CMAKE_INSTALL_RPATH cmake variable, as SOFA CMakeLists are not designed 
# initially for a per-component compilation & installation
cmake ${CMAKE_ARGS} \
  -B . \
  -S ../applications/projects/SceneChecking/ \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DSCENECHECKING_BUILD_TESTS=OFF \
  -DCMAKE_INSTALL_RPATH:PATH=${PREFIX}/lib

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install

cd ..

# runSofa application
# ----------
rm -rf build-sofa-app

mkdir build-sofa-app
cd build-sofa-app

# We have to manually set the Rpath for other SOFA libs to the lib/ directory using
# the CMAKE_INSTALL_RPATH cmake variable, as SOFA CMakeLists are not designed 
# initially for a per-component compilation & installation
cmake ${CMAKE_ARGS} \
  -B . \
  -S ../applications/projects/runSofa/ \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_RPATH:PATH=${PREFIX}/lib

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install

# For macOS, we have to provide this additionnal script as an hotfix
# for users who would like to load SofaPython3 plugin in runSofa
# application.
# See hotfix-sofa-run-macos.sh for more details.
if [[ $target_platform == osx* ]] ; then
    cp "${RECIPE_DIR}/hotfix-sofa-run-macos.sh" "${PREFIX}/bin/runSofa_with_python"
fi

cd ..

# runSofa app requires some data ressources, which will
# be included in this package
# ----------
rm -rf build-sofa-examples

mkdir build-sofa-examples
cd build-sofa-examples

cmake ${CMAKE_ARGS} \
  -B . \
  -S ../examples/ \
  -DCMAKE_BUILD_TYPE:STRING=Release

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install