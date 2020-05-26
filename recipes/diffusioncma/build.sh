mkdir -p build_diffusioncma
cd build_diffusioncma
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DLIBCMAES_ROOT=$PREFIX ../src
make install
make install_python_wrappers
cd ..

${PYTHON} setup.py install

