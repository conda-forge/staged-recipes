#!/bin/sh

mkdir $SRC_DIR/{build,install,config,bin}

##Setup a link to cython here
ln -s $PREFIX/bin/cython $SRC_DIR/bin/cython3

#Setting up some environment variables
export PATH="${PATH}:${SRC_DIR}/bin"
export LD_LIBRARY_PATH=$LD_LIBRARYPATH:$PREFIX/lib

#Set up SConfigISCE file
echo "PYTHON USED = $PYTHON"
export PYTHON_INCDIR=`$PYTHON -c "from sysconfig import get_paths; print(get_paths()['include'])"`
export NUMPY_INCDIR=`$PYTHON -c "import numpy; print(numpy.get_include())"`

echo "
PRJ_SCONS_BUILD = $SRC_DIR/build
PRJ_SCONS_INSTALL = $SRC_DIR/install/isce
LIBPATH = $PREFIX/lib
CPPPATH = $PREFIX/include $PYTHON_INCDIR $NUMPY_INCDIR
FORTRANPATH = $PREFIX/include
CC = $CC
CXX = $CXX
FORTRAN = $FC
MOTIFLIBPATH = $PREFIX/lib
MOTIFINCPATH = $PREFIX/include
X11LIBPATH = $PREFIX/lib
X11INCPATH = $PREFIX/include
" >> $SRC_DIR/config/SConfigISCE


# build isce
export SCONS_CONFIG_DIR=$SRC_DIR/config
cd $SRC_DIR/isce2
scons install --skipcheck 

##Restore environment
unset SCONS_CONFIG_DIR

##Move installation to site-packages
mv $SRC_DIR/install/isce $SP_DIR
rm -rf $SRC_DIR/build

#Move stack processors to share
mkdir -p $PREFIX/share/isce2
mv $SRC_DIR/isce2/contrib/stack/* $PREFIX/share/isce2
mv $SRC_DIR/isce2/contrib/timeseries/* $PREFIX/share/isce2

###Activate/ deactivate scripts
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/isce2-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/isce2-deactivate.sh

