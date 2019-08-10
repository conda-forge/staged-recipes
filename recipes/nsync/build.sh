mkdir -p out
cd out
if [ $(uname) == Linux ]; then
	CMAKE_EXE_LINKER_FLAGS_INIT="-lrt"
fi
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
	  -DCMAKE_PREFIX_PATH=${PREFIX} \
	  -DCMAKE_EXE_LINKER_FLAGS_INIT="${CMAKE_EXE_LINKER_FLAGS_INIT}" \
	  -DCMAKE_INSTALL_LIBDIR=lib \
	  ..
make -j${CPU_COUNT}
make install
