#!/bin/bash

set -x

# Set paths and links:
js_package_path="js-package/build/dist/js/productionExecutable/"
extension_path="python-extension/build/bin/native/releaseStatic/"

# Get Python bin and include directories for the extension build:  
py_bin_path=$($PYTHON -c "from sysconfig import get_paths as gp; print(gp()['scripts'])")
py_include_path=$($PYTHON -c "from sysconfig import get_paths as gp; print(gp()['include'])")
py_architecture=$($PYTHON -c "import platform; print(platform.machine())")
imagemagick_path="$SRC_DIR/platf-imagick/deps"

export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# Set DOCKER_TRUE to "1" to avoid calling Docker in 'init_imagemagick.sh'
export DOCKER_TRUE="1"
./platf-imagick/init_imagemagick.sh

if [ ! -f $extension_path ]; then
   # Runs extension build:
   ./gradlew python-extension:build -Pbuild_release=true -Ppython.bin_path=${py_bin_path} -Ppython.include_path=${py_include_path} -Penable_python_package=true -Parchitecture=${py_architecture} -Pimagemagick_lib_path=${imagemagick_path}
fi


if [ ! -f $js_package_path ]; then
   # Includes JS package to the build:
   ./gradlew js-package:jsBrowserProductionWebpack -Pbuild_release=true -Penable_python_package=false -Parchitecture=${py_architecture}
fi

$PYTHON -m pip install $SRC_DIR/python-package -vv --no-deps --no-build-isolation
