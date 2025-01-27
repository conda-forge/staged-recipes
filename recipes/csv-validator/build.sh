#!/bin/bash

# Note: This will run in a Docker container for building package on Linux
# Copy over .sh and csv-validator-cmd-X.Y.jar and the /lib/ to Conda environment directory (like /home/conda/bin/csv-validator/X.Y)
# Set up environment variables if needed

echo "\$REPO_ROOT" $REPO_ROOT   # Set in .scripts/run_docker_build.sh
echo "\$PREFIX" $PREFIX
echo "\$BUILD_PREFIX" $BUILD_PREFIX
echo "\$ENV_PREFIX" $ENV_PREFIX
echo "\$CONDA_PREFIX" $CONDA_PREFIX
echo "\$PKG_NAME" $PKG_NAME
echo "\$PKG_VERSION" $PKG_VERSION
echo "\$PKG_BUILDNUM" $PKG_BUILDNUM
echo "\$SRC_DIR" $SRC_DIR
echo "\$CONDA_BLD_PATH" $CONDA_BLD_PATH
echo "\n"
printenv
echo "\n"
conda config --show

# Note: $PREFIX, $SRC_DIR, and variables that start with "$PKG_" are defined by main Conda build scripts

# TODO: What is best practice for storing downloaded files from source?
INSTALL_PATH="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"

echo "Installing $PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM to $INSTALL_PATH"

# Creating directories
mkdir -p "$INSTALL_PATH/lib"
mkdir -p "$PREFIX/bin"

echo "Copying files from temp storage to install path..."

# Copying dependencies
# Note: Purposefully not preserving file permissions when copying b/c want to define them in recipe for consistent state
cp -r "$SRC_DIR/lib/"* "$INSTALL_PATH/lib/" || { echo "Failed to copy dependencies"; exit 1; }

# Copying main binary
cp "$SRC_DIR/$PKG_NAME-cmd-$PKG_VERSION.jar" "$INSTALL_PATH/" || { echo "Failed to copy application JAR file"; exit 1; } 

# Copying wrapper bash script
cp "$SRC_DIR/csv-validator-cmd" "$INSTALL_PATH/"  || { echo "Failed to copy wrapper script csv-validator-cmd"; exit 1; }

# Copying LICENSE file
cp "$SRC_DIR/LICENSE" "$INSTALL_PATH/" || { echo "Failed to copy LICENSE"; exit 1; }

# Copying README text
cp "$SRC_DIR/running-csv-validator.txt" "$INSTALL_PATH/" || { echo "Failed to copy running-csv-validator.txt"; exit 1; }

echo "Setting symbolic link and file permissions..."

ln -s $INSTALL_PATH/csv-validator-cmd $PREFIX/bin

chmod 0755 "$PREFIX/bin/csv-validator-cmd"

# TODO: Do we need to perform a clean up operation to remove downloaded files in /work? Or is that handled by Conda?
# I think it's handled by Conda b/c work/ content moved to work_moved_csv-validator-XXX/ after installation

echo "csv-validator-cmd installation complete!"
echo "If you want to change the maximum memory heap allocation (1024 MB default) run "export csvValidatorMemory=\<number in MB\>" before using the csv-validator-cmd command"
echo "See running-csv-validator.txt in the package's installation path for more information"
