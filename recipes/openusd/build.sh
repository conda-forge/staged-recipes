#!/bin/sh

mkdir build
cd build

# -fvisibility-inlines-hidden results in linking errors like:
# testVtCpp.cpp:(.text.startup.main+0x2fa): undefined reference to pxrInternal_v0_25_2__pxrReserved__::VtArray<int>::_DecRef()'
# This is a temporary workaround until https://github.com/PixarAnimationStudios/OpenUSD/pull/3452 is merged upstream,
# that should solve this issue in a clean way
export CFLAGS="$(echo $CFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
export CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fvisibility-inlines-hidden//g')"

# From https://conda-forge.org/docs/maintainer/knowledge_base/#finding-numpy-in-cross-compiled-python-packages-using-cmake
Python_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"
CMAKE_ARGS="${CMAKE_ARGS} -DPython_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}"

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DPXR_HEADLESS_TEST_MODE:BOOL=ON \
      -DPXR_BUILD_IMAGING:BOOL=ON \
      -DPXR_BUILD_USD_IMAGING:BOOL=ON \
      -DPXR_ENABLE_PYTHON_SUPPORT:BOOL=ON \
      -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY:BOOL=ON \
      -DPXR_PYTHON_SHEBANG="/usr/bin/env python"

cmake --build . --config Release
cmake --build . --config Release --target install
# testWorkThreadLimits3 is disabled as it can fail on machines with few cores
# testJsIO is disabled as it now actually links usd_tf, and so the linker remove the link to Python
ctest --output-on-failure -C Release -E "testWorkThreadLimits3|testJsIO"

# The CMake install logic of openusd is not flexible, so let's fix the files
# that should not be installed or should be installed in a different location

# Python files should be moved from $CMAKE_INSTALL_PREFIX/lib/python/pxr to $SP_DIR/pxr
mv $PREFIX/lib/python/pxr $SP_DIR/pxr


# All files installed in $CMAKE_INSTALL_PREFIX/tests, $CMAKE_INSTALL_PREFIX/share/usd/examples and $CMAKE_INSTALL_PREFIX/share/usd/tutorials can be removed
rm -rf $PREFIX/tests
rm -rf $PREFIX/share/usd/examples
rm -rf $PREFIX/share/usd/tutorials

# This logic is to ensure that pip list lists usd-core (https://pypi.org/project/usd-core/) as installed package
# The version style is a bit different: openusd version are something like 22.01, 23.05, 24.11 while usd-core are 22.1, 23.5, 24.11
# so we convert the first occurence of .0 to . if present, to convert from one style to another
PIP_USD_CORE_VERSION=${PKG_VERSION/\.0/.}


# The METADATA file is necessary to ensure that pip list shows the pip package installed by conda
# The INSTALLER file is necessary to ensure that pip list shows that the package is installed by conda
# See https://packaging.python.org/specifications/recording-installed-packages/
# and https://packaging.python.org/en/latest/specifications/core-metadata/#core-metadata

mkdir $SP_DIR/usd_core-$PIP_USD_CORE_VERSION.dist-info

cat > $SP_DIR/usd_core-$PIP_USD_CORE_VERSION.dist-info/METADATA <<METADATA_FILE
Metadata-Version: 2.1
Name: usd-core
Version: $PIP_USD_CORE_VERSION
Summary: Pixar's Universal Scene Description
METADATA_FILE

cat > $SP_DIR/usd_core-$PIP_USD_CORE_VERSION.dist-info/INSTALLER <<INSTALLER_FILE
conda
INSTALLER_FILE
