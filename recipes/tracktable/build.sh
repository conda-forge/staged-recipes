# Build Linux or MacOS package from tracktable source
printenv
mkdir build
cd build
cmake -D BOOST_ROOT:PATH=${BUILD_PREFIX} \
        -D CMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
        -D CMAKE_BUILD_TYPE=Release \
        -D BUILD_DOCUMENTATION=OFF \
        -D Python3_EXECUTABLE:FILEPATH=${PYTHON} \
        -D Python3_ROOT_DIR:PATH=${PREFIX} \
        $SRC_DIR \
        -LA
make -j${CPU_COUNT}
make install
cd ${PREFIX}
${PYTHON} ${SRC_DIR}/packaging/setup-generic.py install
