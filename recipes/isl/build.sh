./configure --prefix="$PREFIX" --with-gmp-prefix="$PREFIX"
make

if [ "$(uname)" = 'Darwin' ]
then
    export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib"
fi
make check

make install-strip
