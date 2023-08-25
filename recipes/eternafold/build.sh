# Move to conda-specific src directory location
cd $SRC_DIR/src

# Build Eternafold
make CXX=$CXX

# Move built binaries to environment-specific location
mkdir -p $PREFIX/bin/eternafold-bin
cp contrafold api_test score_prediction $PREFIX/bin/eternafold-bin

# Move relevant repo files to lib folder
mkdir -p $PREFIX/lib/eternafold-lib
cp -r $SRC_DIR/* $PREFIX/lib/eternafold-lib

# Symlink binary as eternafold and place in PATH-available location
ln -s $PREFIX/bin/eternafold-bin/contrafold $PREFIX/bin/eternafold

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

# Set environment variable pointing to binary
conda env config vars set ETERNAFOLD_PATH=$PREFIX/bin/eternafold
conda env config vars set ETERNAFOLD_PARAMETERS=$PREFIX/lib/eternafold-lib/parameters/EternaFoldParams.v1