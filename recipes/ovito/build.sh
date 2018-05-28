#!/bin/bash

args="-DOVITO_BUILD_PLUGIN_MESH=ON \
      -DOVITO_BUILD_PLUGIN_PARTICLES=ON \
      -DOVITO_BUILD_PLUGIN_TACHYON=OFF \
      -DOVITO_BUILD_PLUGIN_CRYSTALANALYSIS=OFF \
      -DOVITO_BUILD_PLUGIN_NETCDFPLUGIN=OFF \
      -DOVITO_BUILD_PLUGIN_POVRAY=OFF \
      -DOVITO_BUILD_PLUGIN_OPENBABELPLUGIN=OFF \
      -DOVITO_BUILD_PLUGIN_VR=OFF \
      -DOVITO_BUILD_PLUGIN_CORRELATION=ON \
      -DOVITO_BUILD_PLUGIN_VOROTOP=ON \
      -DOVITO_BUILD_GUI=OFF \
      -DOVITO_BUILD_DOCUMENTATION=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${PREFIX}" 

mkdir build
cd build
if [ ${PY3K} = 1 ]; then 
	cmake $args \
	      -DPYTHON_EXECUTABLE=${PREFIX}/bin/python \
	      -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_VER}m \
	      -DPYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_VER}m.so \
	      ..
else 
	cmake $args \
	      -DPYTHON_EXECUTABLE=${PREFIX}/bin/python \
	      -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_VER} \
	      -DPYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_VER}.so \
	      ..
fi;
make 
cp lib/ovito/*.so ${PREFIX}/lib
cp -r lib/ovito/plugins/python/ovito ${SP_DIR}
mkdir -p ${PREFIX}/lib/ovito/plugins
cp lib/ovito/plugins/*.so ${PREFIX}/lib/ovito/plugins
sed -i 's\/../../..\/../../../../ovito/plugins\g' ${SP_DIR}/ovito/plugins/__init__.py
