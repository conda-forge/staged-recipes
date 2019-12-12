export INSTALL_DIR=${INSTALL_DIR:="${PREFIX}"}
export CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:=Release}

./build.sh configure
./build.sh install
