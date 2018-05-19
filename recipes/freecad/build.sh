mkdir -p build
cd build

if [ `uname` = "Darwin" ]; then
      NETGEN_VAR="-D BUILD_FEM_NETGEN=OFF \
                 "
else
      NETGEN_VAR="-D NETGENDATA:FILEPATH=$PREFIX/include/netgen \
                  -D NETGEN_INCLUDEDIR:FILEPATH=$PREFIX/include/netgen \
                  -D NGLIB_INCLUDE_DIR:FILEPATH=$PREFIX/include/nglib \
                  -D BUILD_FEM_NETGEN:BOOL=ON \
                 "
fi

cmake -G "Ninja" \
      -D BUID_WITH_CONDA:BOOL=ON \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D CMAKE_PREFIX_PATH:FILEPATH=$PREFIX \
      -D CMAKE_LIBRARY_PATH:FILEPATH=$PREFIX/lib \
      -D BUILD_QT5:BOOL=ON \
       ${NETGEN_VAR} \
      -D OCC_INCLUDE_DIR:FILEPATH=$PREFIX/include/opencascade \
      -D OCC_LIBRARY_DIR:FILEPATH=$PREFIX/lib \
      -D OCC_LIBRARIES:FILEPATH=$PREFIX/lib CACHE PATH \
      -D FREECAD_USE_OCC_VARIANT="Official Version" \
      -D OCC_OCAF_LIBRARIES:FILEPATH=$PREFIX/lib CACHE PATH \
      -D SWIG_DIR:FILEPATH=$PREFIX/share/swig/3.0.8 \
      -D SWIG_EXECUTABLE:FILEPATH=$PREFIX/bin/swig \
      -D PYTHON_EXECUTABLE:FILEPATH=$PYTHON \
      -D USE_BOOST_PYTHON:BOOL=OFF \
      -D FREECAD_USE_PYBIND11:BOOL=ON \
      -D BUILD_ENABLE_CXX11:BOOL=ON \
      -D SMESH_INCLUDE_DIR:FILEPATH=$PREFIX/include/smesh \
      -D FREECAD_USE_EXTERNAL_SMESH=ON \
      -D BUILD_FLAT_MESH:BOOL=ON \
      ..

ninja -j${CPU_COUNT} install

rm ${PREFIX}/doc -r     # smaller size of package!
