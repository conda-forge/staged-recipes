
# build libcmaes when not on MacOS
#if [ "$(uname)" != "Darwin" ]; then	
echo "Building libcmaes..."
mkdir -p build_libcmaes
cd build_libcmaes
cmake \
    -DCMAKE_INSTALL_PREFIX=../install_libcmaes \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_PYTHON=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DLINK_PYTHON=OFF \
    -DUSE_COMPILE_FEATURES=OFF \
    ../src/libcmaes
make install
cd ..
#fi


echo "Building diffusioncma..."

mkdir -p build_diffusioncma
cd build_diffusioncma
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DLIBCMAES_ROOT=../install_libcmaes ../src
make install
make install_python_wrappers
cd ..

${PYTHON} setup.py install

