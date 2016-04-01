#!/bin/bash

# Setup CMake build location
mkdir build
cd build

# Configure, build, test, and install.
cmake -DCPU_ONLY=1 -DBLAS="open" -DCMAKE_INSTALL_PREFIX="${PREFIX}" ..
make
make runtest
make install

# Python installation is non-standard. So, we're fixing it.
mv "${PREFIX}/python/caffe" "${SP_DIR}/"
for FILENAME in $( cd "${PREFIX}/python/" && find . -name "*.py" | sed 's|./||' );
do
    chmod +x "${PREFIX}/python/${FILENAME}"
    cp "${PREFIX}/python/${FILENAME}" "${PREFIX}/bin/${FILENAME//.py}"
done
rm -rf "${PREFIX}/python/"
