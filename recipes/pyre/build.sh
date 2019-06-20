#!/bin/sh

# Workaround for PROJ_LIB clobbering by mm internally
export RECIPE_CONDA_PROJ_LIB=$PROJ_LIB
unset PROJ_LIB

# Use conda compiler + options
export COMPILER_CXX_NAME=$CXX
export DEV_CXX_FLAGS=$CXXFLAGS
export DEV_LCXX_FLAGS=$LDFLAGS
unset CXXFLAGS

# Misc environment info for mm
export BLD_CONFIG=$SRC_DIR/config
export EXPORT_ROOT=$SRC_DIR/install
export PATH=$PATH:$EXPORT_ROOT/bin
export PYTHONPATH=$PYTHONPATH:$EXPORT_ROOT/packages
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$EXPORT_ROOT/lib
export MM_INCLUDES=$EXPORT_ROOT/include
export MM_LIBPATH=$EXPORT_ROOT/lib

# Get python compilation options
# PYTHON is also clobbered by mm in configuration
RECIPE_CONDA_PYTHON=$PYTHON
export PYTHON=`$RECIPE_CONDA_PYTHON -c "import sysconfig; print(sysconfig.get_config_var('CONFINCLUDEPY').split('/')[-1])"`
export PYTHON_DIR=$PREFIX
export PYTHON_INCDIR=`$RECIPE_CONDA_PYTHON -c "from sysconfig import get_paths; print(get_paths()['include'])"`
export PYTHON_LIB=$PYTHON
export PYTHON_LIBDIR=$PREFIX/lib
export PYTHON_PYCFLAGS=-b

echo "MM ENVIRONMENT-----------"
env
echo "MM END ------------------"

touch $PREFIX/include/portinfo
mkdir $SRC_DIR/{build,install}
cd $SRC_DIR/pyre

$RECIPE_CONDA_PYTHON $SRC_DIR/config/make/mm.py build

# Symlink libraries, binaries, python packages, etc.
mv $EXPORT_ROOT/packages/* $SP_DIR
mv $EXPORT_ROOT/include/* $PREFIX/include/
mv $EXPORT_ROOT/bin/* $PREFIX/bin/
mv $EXPORT_ROOT/lib/* $PREFIX/lib/
