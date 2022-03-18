#!/bin/bash

"${PYTHON}" -m pip install . -vv

if [[ $target_platform == linux* ]]; then
"$CC" -shared -o $SP_DIR/goodvibes/share/symmetry_test.so -fPIC symmetry.c
else
"$CC" -dynamiclib symmetry.c -o $SP_DIR/goodvibes/share/symmetry_mac.dylib -current_version 1.0 -compatibility_version 1.0
fi