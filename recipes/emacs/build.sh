if [ "$(uname)" == "Darwin" ]; then
    OPTS=""
else
    OPTS="--x-includes=$PREFIX/include --x-libraries=$PREFIX/lib"
fi

bash configure  --prefix=$PREFIX $OPTS

make
make check
make install
