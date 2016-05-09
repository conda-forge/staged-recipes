./bootstrap $PREFIX

# ./configure --srcdir=`pwd` \
#             --prefix=$PREFIX \
#             --enable-debug \
#             --enable-automated \
#             --enable-basic \
#             --enable-console \
#             --enable-examples \
#             --enable-test

make
make check
make install
