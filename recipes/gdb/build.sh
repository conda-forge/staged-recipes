#!/bin/bash

# Download the right script to debug python processes
curl -SL https://hg.python.org/cpython/raw-file/$PY_VER/Tools/gdb/libpython.py \
    > "$SP_DIR/libpython.py"

# Install a gdbinit file that will be automatically loaded
echo '
python
import gdb
import sys
import os
def setup_python(event):
    import libpython
gdb.events.new_objfile.connect(setup_python)
end
' >> "$PREFIX/etc/gdbinit"

# Setting /usr/lib/debug as debug dir makes it possible to debug the system's
# python on most Linux distributions
export CFLAGS="-I$PREFIX/include -L$PREFIX/lib"
./configure \
    --prefix="$PREFIX" \
    --with-separate-debug-dir="$PREFIX/lib/debug:/usr/lib/debug" \
    --with-python \
    --with-system-gdbinit="$PREFIX/etc/gdbinit"
make -j${CPU_COUNT}
make install
