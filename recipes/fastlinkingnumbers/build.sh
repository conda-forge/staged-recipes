
mkdir build
cd build
cmake ..
make
# Copy executables
mkdir -p $PREFIX/bin
cp verifycurves $PREFIX/bin/
cp obj2bcc $PREFIX/bin/
# Copy shared library
mkdir -p $PREFIX/lib
cp -P libverifycurves* $PREFIX/lib/
# Copy public headers, prepending library name
mkdir -p $PREFIX/include
for f in ../include/*; do
    name=${f##*/}
    cp -- "$f" "$PREFIX/include/libverifycurves_$name"
done

