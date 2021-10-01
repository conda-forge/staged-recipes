
mkdir build
cd build
cmake ..
make
# Copy executables
mkdir -p $PREFIX/bin
cp verifycurves $PREFIX/bin/
cp obj2bcc $PREFIX/bin/
# Copy shared library and headers
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include
cp -P libverifycurves* $PREFIX/lib
cp ../include/* $PREFIX/include
