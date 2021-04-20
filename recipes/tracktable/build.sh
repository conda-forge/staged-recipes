
set -o nounset

# Build Linux or MacOS package from tracktable source
if [[ $(uname) == Linux ]]; then
    printenv
    if [ -d "build" ]; then
        cd build
        make clean
    else
        mkdir build
        cd build
    fi
    cmake -D BOOST_ROOT:PATH=${BUILD_PREFIX} \
          -D CMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
          -D CMAKE_BUILD_TYPE=Release \
          -D BUILD_DOCUMENTATION=OFF \
          -D Python3_EXECUTABLE:FILEPATH=${PYTHON} \
          -D Python3_ROOT_DIR:PATH=${PREFIX} \
          $SRC_DIR \
          -LA
    make -j${CPU_COUNT}
    # ctest
    make install
    cd ${PREFIX}
    ${PYTHON} ${SRC_DIR}/packaging/setup-generic.py install
elif [[ $(uname) == Darwin ]]; then
    echo MacOS Build Commands
fi
