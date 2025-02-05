mkdir build_core install_core
cd build_core
export ISISROOT=$PWD

cmake -GNinja -DBUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release -DISIS_BUILD_SWIG=ON -DCMAKE_INSTALL_PREFIX=../install_core ../isis/src/core
ninja core && ninja install

echo "Finding libcore.so . . ."
find ../install_core -name "libcore.so"

cd swig/python/
${PYTHON} setup.py install

echo "Running ldd . . ."
ldd ../install_core/lib/python3.11/site-packages/isiscore/_isiscore.so