#!/bin/bash -x

## create the SConstruct file
if [ ! -e SConstruct ]; then
    ln -s SConsTools/src/SConstruct.main SConstruct
fi

## setup needed environment variables, if not defined,
if [ -z "$SIT_ARCH" ]; then
    export SIT_ARCH=x86_64-rhel7-gcc48-opt
    echo "SIT_ARCH was not defined, set it to $SIT_ARCH"
fi

export SIT_RELEASE=`cat .sit_release`

if [ -z "$SIT_ROOT" ]; then
    export SIT_ROOT=/reg/g/psdm
    echo "SIT_ROOT was not defined, set it to $SIT_ROOT"
fi


export SIT_USE_CONDA=1

if [ -z $PREFIX ]; then
    echo "WARNING: PREFIX is not defined, script is not being run from conda-build, setting PREFIX for development purposes"
    export PREFIX=$CONDA_PREFIX
fi

export CONDA_ENV_PATH=$PREFIX

if [ ! -e '.sit_conda_env' ]; then
    echo $CONDA_ENV_PATH > '.sit_conda_env'
    echo "created .sit_conda_env file with $CONDA_ENV_PATH"
fi

CURDIR=`pwd`
export SIT_DATA="$CURDIR/data:$SIT_ROOT/data"
echo "set SIT_DATA to $SIT_DATA"

# build
CWD=$(pwd)
echo "Current dir: $CWD"

# needed to avoid file locking crash in mpi splitscan tests
export HDF5_USE_FILE_LOCKING=FALSE

export PYTHONPATH=$CWD/arch/$SIT_ARCH/python:$PYTHONPATH
export LD_LIBRARY_PATH=$CWD/arch/$SIT_ARCH/lib:$CONDA_PREFIX/lib
# put ana release bin second in path
export PATH=$CWD/arch/$SIT_ARCH/bin:$PATH
export PATH=$CONDA_ENV_PATH/bin:$PATH

echo "######## env ############"
env
echo "#########################"

mkanarel='SConsTools/src/tools/anarelinfo.py'
if [ ! -e "$mkanarel" ]; then
   echo "Script to make anarel info not found: $mkanarel"
   return
fi

# patch the pdsdata/psalg makefiles to use the conda compilers
sed -i 's/gcc/$(CC)/g' extpkgs/psalg/package.mk
sed -i 's/g++/$(CXX)/g' extpkgs/psalg/package.mk
sed -i 's/gcc/$(CC)/g' extpkgs/pdsdata/package.mk
sed -i 's/g++/$(CXX)/g' extpkgs/pdsdata/package.mk
sed -i 's/gcc/$(CC)/g' extpkgs/pdsdata/flags.mk
sed -i 's/g++/$(CXX)/g' extpkgs/pdsdata/flags.mk

# first we run mkanarel. This creates a new package called
# anarelinfo. It will be a python module with the psana-conda
# version and tag information, it will also copy psana-conda-tags
# into the data subdir.

# after running scons, we run it again, but know with the 
# copy_depends argument. This will copy the '.pkg_tree.pkl'
# file into anarelinfo/data so that it will get installed 
# in conda.

${PREFIX}/bin/python $mkanarel 
${PREFIX}/bin/scons
${PREFIX}/bin/python $mkanarel copy_depends

# need to switch back to full testing once they work - cpo
#${PREFIX}/bin/scons test-psana
#${PREFIX}/bin/scons test

${PREFIX}/bin/scons conda-install

# generate config file to export psana environment variables when activating the conda environment
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

cat <<EOF > $PREFIX/etc/conda/activate.d/env_vars.sh
export SIT_DATA=$PREFIX/data:/reg/g/psdm/data
export SIT_ARCH=$SIT_ARCH
export SIT_ROOT=/reg/g/psdm
EOF

cat <<EOF > $PREFIX/etc/conda/deactivate.d/env_vars.sh
unset SIT_DATA
unset SIT_ARCH
unset SIT_ROOT
EOF
