mkdir build -p
cd build 

if [[ ${HOST} =~ .*linux.* ]]; then
	# https://github.com/conda-forge/boost-feedstock/issues/72
	sed -i '127s#;##g' ${PREFIX}/include/boost/python/detail/caller.hpp
fi

cmake -G "Ninja" \
      -D CMAKE_BUILD_TYPE:STRING=Release \
      -D CMAKE_PREFIX_PATH:FILEPATH=$PREFIX \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D BUILD_PY_LIB:BOOL=ON \
      -D USE_PY_3:BOOL=ON \
      -D Boost_NO_BOOST_CMAKE:BOOL=ON \
      -D VERSION_STRING:STRING="${PKG_VERSION}" \
      ../src

ninja install