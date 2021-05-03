# Build Linux or MacOS package from tracktable source
mkdir build
cd build
cmake ${CMAKE_ARGS} \
        -D CMAKE_BUILD_TYPE=Release \
        -D BUILD_DOCUMENTATION=OFF \
        -D Python3_EXECUTABLE:FILEPATH=${PYTHON} \
        -D Python3_ROOT_DIR:PATH=${PREFIX} \
        $SRC_DIR
make -j${CPU_COUNT}
make install
cd ${PREFIX}
${PYTHON} ${SRC_DIR}/packaging/setup-generic.py install
