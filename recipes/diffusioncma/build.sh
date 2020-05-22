
# build libcmaes when not on MacOS
#if [ "$(uname)" != "Darwin" ]; then	
echo "Building libcmaes..."
mkdir -p build_libcmaes
cd build_libcmaes
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release ../src/libcmaes
make install
cd ..
#fi


echo "Building diffusioncma..."

mkdir -p build_diffusioncma
cd build_diffusioncma
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DLIBCMAES_ROOT=$PREFIX ../src
make install
make install_python_wrappers
cd ..

${PYTHON} setup.py install

