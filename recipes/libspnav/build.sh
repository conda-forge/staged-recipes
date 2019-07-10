#autoreconf --install
#chmod +x configure
./configure --prefix="$PREFIX/Library" --libdir="$PREFIX/Library/lib"
make CC="${CC}" AR="${AR}"
make install
