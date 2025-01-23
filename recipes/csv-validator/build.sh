#!/bin/bash

# Download .zip to a temp directory
# Unzip
# Copy over .sh and csv-validator-cmd-X.Y.jar and the /lib/ to Conda environment directory
# Set up environment variables if needed

echo $PREFIX    # TODO: I don't think $PREFIX and $SRC_DIR are defined in Conda; in BioConda they are
echo $BUILD_PREFIX
echo $PKG_NAME
echo $PKG_VERSION
echo $PKG_BUILDNUM
echo $SRC_DIR
echo $CONDA_BLD_PATH

# TODO: What is best practice for storing downloaded files from source?
INSTALL_PATH="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"

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
