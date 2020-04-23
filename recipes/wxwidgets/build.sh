./configure --prefix=${PREFIX} --with-gtk="3"

make -j ${CPU_COUNT}
make install
