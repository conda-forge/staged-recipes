ln -s "${PREFIX}/lib" "${PREFIX}/lib64"

./configure --prefix="${PREFIX}"
make
make install

rm "${PREFIX}/lib64"
