if [ "$(uname)" == "Darwin" ]; then
    # Feel free to remove this if you can figure out how to make it build.
    OPTS="--without-x"
else
    OPTS="--x-includes=$PREFIX/include --x-libraries=$PREFIX/lib"
fi

bash configure  --prefix=$PREFIX $OPTS

make
make check
make install
