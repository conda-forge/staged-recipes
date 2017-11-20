#!/bin/bash

mkdir -p "$PREFIX/Menu"
if [ $OSX_ARCH ]
then
    cp "$RECIPE_DIR/larray-editor.json" "$PREFIX/Menu"
    cp "$SRC_DIR/larray_editor/images/larray.png" "$PREFIX/Menu"
else
    cp "$RECIPE_DIR/larray-editor.json" "$PREFIX/Menu"
    cp "$SRC_DIR/larray_editor/images/larray.png" "$PREFIX/Menu"
fi

"$PYTHON" setup.py install || exit 1
