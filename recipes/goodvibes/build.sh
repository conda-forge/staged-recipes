#!/bin/bash

mv "$SRC_DIR/goodvibes/share/symmetry.c" symmetry.c
mv "$SRC_DIR/goodvibes/share/LICENSE.txt" symmetry.LICENSE.txt
rm -rf "$SRC_DIR/goodvibes/share/"

"${PYTHON}" -m pip install . -vv

mkdir "$SP_DIR/goodvibes/share"
if [[ $target_platform == linux* ]]; then
  "$CC" -shared -o "$SP_DIR/goodvibes/share/symmetry_linux.so" -fPIC symmetry.c
else
  "$CC" -dynamiclib symmetry.c -o "$SP_DIR/goodvibes/share/symmetry_mac.dylib" -current_version 1.0 -compatibility_version 1.0
fi
