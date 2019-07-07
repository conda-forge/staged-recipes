#autoreconf --install
#chmod +x configure
./configure --prefix="$PREFIX/Library" --libdir="$PREFIX/Library/lib"
make
make install