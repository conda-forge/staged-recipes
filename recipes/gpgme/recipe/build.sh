./configure --prefix=$PREFIX \
	--disable-gpgsm-test \
	--disable-gpgconf-test \
	--disable-g13-test \
	--disable-gpg-test \
	--enable-languages="no"

make -j${CPU_PROC}

make install