./configure --cc="$GCC" --cxx="$GXX" --prefix="$PREFIX" --disable-static
make -C src
make install
