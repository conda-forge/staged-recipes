#!/bin/bash
set -ex

# for subpackages, we have named our extracted locations according to the subpackage name
#    That's what this $PKG_NAME is doing - picking the right subfolder to rsync

src="$SRC_DIR/$PKG_NAME"
# not all packages have the license file.  Copy it from mkl, where we know it exists
cp -f "$SRC_DIR/mkl/info/LICENSE.txt" "$SRC_DIR"
cp -rv "$src"/* "$PREFIX/"

# ro by default.  Makes installations not cleanly removable.
chmod 664 "$SRC_DIR/LICENSE.txt"

# replace old info folder with our new regenerated one
rm -rf "$PREFIX/info"
