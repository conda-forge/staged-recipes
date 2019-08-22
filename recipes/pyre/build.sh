#!/bin/sh
set -euo pipefail

os_type=`uname`
if [ "$os_type" = "Darwin" ]; then
    export TARGET_CXX=clang-4
    # Use specified macOS SDK, and enforce minimum version
    export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
fi

# Use conda compiler + options
export COMPILER_CXX_NAME=$CXX
# Set these variables so as not to clobber mm flags
export DEV_CXX_FLAGS=$CXXFLAGS
export DEV_LCXX_FLAGS=$LDFLAGS
unset LDFLAGS
unset CXXFLAGS

# Get python compilation options
export PYTHON_INCDIR=`$PYTHON -c "from sysconfig import get_paths; print(get_paths()['include'])"`
export PYTHON_LIBDIR=`$PYTHON -c "from sysconfig import get_config_var; print(get_config_var('LIBDIR'))"`
export PYTHON_LIB=`$PYTHON -c "from sysconfig import get_config_var; print(get_config_var('LDLIBRARY'))" | sed 's/lib\(.*\)\..*/\1/g'`

# Build
cd $SRC_DIR/pyre
$PYTHON $SRC_DIR/config/make/mm.py build --prefix=$PREFIX

# Install python packages to conda's site-package directory
mv $PREFIX/packages/* $SP_DIR/
