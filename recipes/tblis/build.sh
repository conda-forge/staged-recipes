CFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")

./configure --prefix=$PREFIX --enable-config=x86 --disable-static
make -j${CPU_COUNT}
make install

