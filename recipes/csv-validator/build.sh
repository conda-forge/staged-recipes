#!/bin/bash

# Note: This will run in a Docker container for building package on Linux
# Copy over .sh and csv-validator-cmd-X.Y.jar and the /lib/ to Conda environment directory (like /home/conda/bin/csv-validator/X.Y)
# Set up environment variables if needed

echo "\$REPO_ROOT" $REPO_ROOT   # Set in .scripts/run_docker_build.sh
echo "\$PREFIX" $PREFIX    # TODO: I don't think $PREFIX and $SRC_DIR are defined in Conda; in BioConda they are
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

# Note: Variables that start with "$PKG_" are defined by main Conda build script

# TODO: What is best practice for storing downloaded files from source?
INSTALL_PATH="$BUILD_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"

echo $INSTALL_PATH

# Creating directories
[ -d "$INSTALL_PATH" ] || mkdir -p "$INSTALL_PATH"
[ -d "$PREFIX/bin" ] || mkdir -p "$PREFIX/bin"

# TODO: This path doesn't exist according to python build-locally.py
cp -r "$SRC_DIR/lib/*" "$INSTALL_PATH/lib"      # Copying dependencies
cp -p "$SRC_DIR/$PKG_NAME-cmd-$PKG_VERSION.jar" "$INSTALL_PATH"          # Copying main binary
cp "$SRC_DIR/csv-validator-cmd" "$INSTALL_PATH/csv-validator-cmd" # Copying bash script

# TODO: Verify file paths for package and what environment variables are set by Conda build process
ln -s $INSTALL_PATH/csv-validate $PREFIX/bin    # Setting symbolic link

chmod 0755 "$PREFIX/bin/csv-validate"   # Allowing permission to execute script
