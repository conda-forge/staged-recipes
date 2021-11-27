echo "some sed"
# Remove buildroot traces
sed -i.bak -e "s,${SRC_DIR}/tk_source/unix,${PREFIX}/lib,g" -e "s,${SRC_DIR}/tk_source,${PREFIX}/include,g" ${PREFIX}/lib/tkConfig.sh

locate tkConfig.sh
./configure --exec-prefix=$LIBRARY_PREFIX/ --with-tcl=$LIBRARY_PREFIX/lib/ --with-tk=$LIBRARY_PREFIX/lib/  --enable-threads
make
make install
