#!/bin/sh
# NOTE : A local download preserves the perimissions but for some reason the
# download on CircleCI's docker image does not. So the following line is
# required.
chmod +x configure
mkdir build
cd build
# NOTE : configure doesn't seem to find mpfr automatically, so the extra flags
# are needed.
../configure \
	--prefix=$PREFIX \
	--disable-qt \
	-with-mpfr-include=$PREFIX/include \
	-with-mpfr-lib=$PREFIX/lib
make -j${CPU_COUNT}
make install
