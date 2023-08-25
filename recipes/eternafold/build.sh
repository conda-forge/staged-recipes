# Move to conda-specific src directory location
cd $SRC_DIR/src

# Build Eternafold
make CXX=$CXX

# Move built binaries to environment-specific location
mkdir -p $PREFIX/bin/eternafold-bin
cp contrafold api_test score_prediction $PREFIX/bin/eternafold-bin

# Move relevant repo files to lib folder
cp -r $SRC_DIR $PREFIX/lib/eternafold-lib

# Symlink binary as eternafold and place in PATH-available location
ln -s $PREFIX/bin/eternafold-bin/contrafold $PREFIX/bin/eternafold

# Set environment variable pointing to binary
conda env config vars set ETERNAFOLD_PATH=$PREFIX/bin/eternafold
conda env config vars set ETERNAFOLD_PARAMETERS=$PREFIX/lib/eternafold-lib/parameters/EternaFoldParams.v1