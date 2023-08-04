# Move to conda-specific src directory location
cd %SRC_DIR%\src

# Build Eternafold
make CXX=%CXX%

# Move built binaries to environment-specific location
mkdir -p %PREFIX%\bin\eternafold-bin
cp contrafold api_test score_prediction %PREFIX%\bin\eternafold-bin

# Symlink binary as eternafold and place in PATH-available location
ln -s %PREFIX%\bin\eternafold-bin\contrafold %PREFIX%\bin\eternafold
