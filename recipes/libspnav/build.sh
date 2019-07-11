./configure --prefix="$PREFIX" --libdir="$PREFIX/lib"
make CC="${CC}" AR="${AR}" incpaths= libpaths=
make install
