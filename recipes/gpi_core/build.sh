#!/bin/bash

set -x

UNPACK_DIR=repo_contents

# Move files to root dir to avoid a License file error 
mv $UNPACK_DIR/{AUTHORS,COPYING,COPYING.LESSER,LICENSE,README.md} .

# Make the site-packages directory
mkdir -p $SP_DIR/$PKG_NAME

# Copy all of the appropriate things there
cp -R $UNPACK_DIR/* $SP_DIR/$PKG_NAME
cp {AUTHORS,COPYING,COPYING.LESSER,LICENSE,README.md} $SP_DIR/$PKG_NAME

# Do the build in place in site-packages
cd $SP_DIR/$PKG_NAME
for LIB_DIR in ./*/; do (cd "$LIB_DIR" && gpi_make --all --ignore-gpirc -r 2); done

# drop a version file with parseable info
VERSION_FPATH=$SP_DIR/$PKG_NAME/VERSION
echo "PKG_NAME: $PKG_NAME" > $VERSION_FPATH
echo "PKG_VERSION: $PKG_VERSION" >> $VERSION_FPATH
echo "GIT_FULL_HASH: $GIT_FULL_HASH" >> $VERSION_FPATH
BUILD_DATE=`date +%Y-%m-%d`
echo "BUILD_DATE: $BUILD_DATE" >> $VERSION_FPATH
