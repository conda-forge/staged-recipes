#!/bin/bash

cd $SRC_DIR/src
make clean
make USE_MKL=0 USE_SCALAPACK=1 USE_FFTW=1

echo "Installing sparc into $PREFIX/bin"
cp $SRC_DIR/lib/sparc $PREFIX/bin

echo "Moving sparc psp into $PREFIX/share/sparc/psps"
mkdir -p $PREFIX/share/sparc/psps
cp $SRC_DIR/psps/* $PREFIX/share/sparc/psps/
mkdir -p $PREFIX/doc/sparc
cp -r $SRC_DIR/doc/ $PREFIX/doc/sparc/
echo "Finish compiling sparc!"

# Copy activate and deactivate scripts
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate-sparc.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate-sparc.sh
echo "Finish setting up activate / deactivate scripts"