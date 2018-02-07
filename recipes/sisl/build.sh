#!/bin/sh

# There are some issues in the linking on Py3 vs Py2
# Hence we need to figure out the exact library name and link directly
# to fix the f2py linking step.
if [ $(uname) == "Darwin" ]; then
    python_lib=$(basename $(otool -L $PYTHON | grep 'libpython.*\.dylib' | tr '\t' ' ' | cut -d' ' -f2))
     #| sed -e 's/lib/-l/; s/\.dylib.*//')
    python_lib=${python_lib//libpython/-lpython}
    python_lib=${python_lib//.dylib*/}
    export LDFLAGS="-shared $LDFLAGS ${python_lib}"
else
    # This is the required steps for Linux boxes when forcing the
    # python linker lines
    #python_lib=$(ldd $(which $PYTHON) | grep 'libpython.*\.so' | cut -d' ' -f1)
    #python_lib=${python_lib// /}
    #python_lib=${python_lib//libpython/-lpython}
    #python_lib=${python_lib//.so*}
    #export LDFLAGS="-shared $LDFLAGS ${python_lib}"
    export LDFLAGS="-shared $LDFLAGS"
fi
$PYTHON setup.py install --single-version-externally-managed --record record.txt
