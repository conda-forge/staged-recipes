./configure --prefix="$PREFIX" --libdir="$PREFIX/lib"
make CC="${CC}" AR="${AR}" incpaths=-I. libpaths=
make install
