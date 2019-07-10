#autoreconf --install
#chmod +x configure
CC="${CC}"
AR="${AR}"
./configure --prefix="$PREFIX/Library" --libdir="$PREFIX/Library/lib"
make
make install
