# DEBUGGING
ls -al

if [ "$(uname)" == "Darwin" ]; then
    ./configure  --prefix=$PREFIX --without-x
else
    ./configure  --prefix=$PREFIX --x-includes=$PREFIX/include --x-libraries=$PREFIX/lib
fi

make && make install
