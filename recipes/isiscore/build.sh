mkdir build_core install_core
cd build_core
export ISISROOT=$PWD

cmake -GNinja -DBUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release -DISIS_BUILD_SWIG=ON -DCMAKE_INSTALL_PREFIX=../install_core ../isis/src/core
ninja core && ninja install
cd swig/python/
${PYTHON} setup.py install

find . -name "_isiscore.so"

readelf -d $PREFIX/lib/python3.11/site-packages/isiscore/_isiscore.so | grep RPATH

find $PREFIX -name "_isiscore.so"
