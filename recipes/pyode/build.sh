# part 1, library, cmake and c++
mkdir _build
cd _build

cmake -DODE_WITH_DEMOS:BOOL=OFF \
      -DODE_WITH_TESTS:BOOL=OFF .. \
      -DCMAKE_INSTALL_PREFIX:PATH=""

make install DESTDIR="${PREFIX}"
cd ..

# part 2, bindings; c and cython
cd bindings/python
python setup.py install --root "${PREFIX}" --prefix ""
