#!/bin/sh

rm -rf build
mkdir -p build

cd build

cmake ${CMAKE_ARGS} -GNinja -DPYTHON_EXECUTABLE=$PYTHON .. \
    -DBUILD_TESTING:BOOL=ON
cat CMakeCache.txt

cmake --build . --config Release
cmake --build . --config Release --target install

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  ctest --output-on-failure -C Release
fi

# The METADATA file is necessary to ensure that pip list shows the pip package installed by conda
# The INSTALLER file is necessary to ensure that pip list shows that the package is installed by conda
# See https://packaging.python.org/specifications/recording-installed-packages/
# and https://packaging.python.org/en/latest/specifications/core-metadata/#core-metadata

mkdir $SP_DIR/placo-$PKG_VERSION.dist-info

cat > $SP_DIR/placo-$PKG_VERSION.dist-info/METADATA <<METADATA_FILE
Metadata-Version: 2.1
Name: placo
Version: $PKG_VERSION
Summary: Rhoban Planning and Control
METADATA_FILE

cat > $SP_DIR/placo-$PKG_VERSION.dist-info/INSTALLER <<INSTALLER_FILE
conda
INSTALLER_FILE
