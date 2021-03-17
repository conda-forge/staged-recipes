#!/usr/bin/env bash

echo "**** Setting up util/dist_prefs"

cat <<EOF >> util/dist_prefs
export DIST_F90_REQUEST="gfortran"
export ACC_PLOT_PACKAGE="pgplot"
export ACC_PLOT_DISPLAY_TYPE="X"
export ACC_ENABLE_OPENMP="Y"
export ACC_ENABLE_MPI="N"
export ACC_FORCE_BUILTIN_MPI="N"
export ACC_ENABLE_GFORTRAN_OPTIMIZATION="Y"
export ACC_ENABLE_SHARED="Y"
export ACC_ENABLE_FPIC="Y"
export ACC_ENABLE_PROFILING="N"
export ACC_SET_GMAKE_JOBS="2"
export ACC_CONDA_BUILD="Y"
EOF

echo "**** Invoking dist_source_me"
source util/dist_source_me

if [[ "$target_platform" == linux-* ]]; then
  echo "**** creating gfortran link "
  ln -s $GFORTRAN $BUILD_PREFIX/bin/gfortran
fi

echo "**** which gfortran "
which gfortran

echo "**** Invoking dist_build_production"
util/dist_build_production

# create folders if they don't exist yet
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include/bmad
mkdir -p $PREFIX/share/doc/tao

## install products
# binaries
cp -r production/bin/* $PREFIX/bin/.
# headers
cp -r production/include/* $PREFIX/include/.
# libraries
cp -r production/lib/* $PREFIX/lib
# fortran modules
cp -r production/modules/* $PREFIX/include/bmad/.
# tao documenation files
cp -r tao/doc/ $PREFIX/share/doc/tao/.

# Create auxiliary dirs
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

# Create auxiliary vars
ACTIVATE=$PREFIX/etc/conda/activate.d/bmad
DEACTIVATE=$PREFIX/etc/conda/deactivate.d/bmad

# Variable TAO_DIR is used by Tao to find auxiliary documentation files
echo "export TAO_DIR=\$CONDA_PREFIX/share/doc/tao/" >> $ACTIVATE.sh
echo "unset TAO_DIR" >> $DEACTIVATE.sh

unset ACTIVATE
unset DEACTIVATE
