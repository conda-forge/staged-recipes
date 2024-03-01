./configure --cc="$GCC" --cxx="$GXX" --prefix="$PREFIX"
make -C src
make install
rm "$PREFIX"/lib/*.a
