mkdir -p build
cd build

if [ `uname` = "Darwin" ]; then
      NETGEN_VAR="-D BUILD_FEM_NETGEN=OFF \
                 "
      QT_VAR="-D BUILD_WEB:BOOL=OFF \
              -D BUILD_START:BOOL=OFF \
             "
else
      NETGEN_VAR="-D NETGENDATA:FILEPATH=$PREFIX/include/netgen \
                  -D NETGEN_INCLUDEDIR:FILEPATH=$PREFIX/include/netgen \
                  -D NGLIB_INCLUDE_DIR:FILEPATH=$PREFIX/include/nglib \
                  -D BUILD_FEM_NETGEN:BOOL=ON \
                 "
      QT_VAR="-D BUILD_WEB:BOOL=ON \
             "
fi

PY_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")
PY_LIBRARY_DIR=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))")

cmake -G "Ninja" \
      -D BUID_WITH_CONDA:BOOL=ON \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D CMAKE_PREFIX_PATH:FILEPATH=$PREFIX \
      -D CMAKE_LIBRARY_PATH:FILEPATH=$PREFIX/lib \
      -D BUILD_QT5:BOOL=ON \
       ${NETGEN_VAR} \
       ${QT_VAR} \
      -D OCC_INCLUDE_DIR:FILEPATH=$PREFIX/include/opencascade \
      -D OCC_LIBRARY:FILEPATH=$PREFIX/lib \
      -D FREECAD_USE_OCC_VARIANT="Official Version" \
      -D SWIG_DIR:FILEPATH=$PREFIX/share/swig/3.0.8 \
      -D SWIG_EXECUTABLE:FILEPATH=$PREFIX/bin/swig \
      -D PYTHON_EXECUTABLE:FILEPATH=$PYTHON \
      -D PYTHON_INCLUDE_DIR:FILEPATH=${PY_INCLUDE_DIR} \
      -D PYTHON_LIBRARY_DIR:FILEPATH=${PY_LIBRARY_DIR} \
      -D USE_BOOST_PYTHON:BOOL=OFF \
      -D FREECAD_USE_PYBIND11:BOOL=ON \
      -D BUILD_ENABLE_CXX11:BOOL=ON \
      -D SMESH_INCLUDE_DIR:FILEPATH=$PREFIX/include/smesh \
      -D FREECAD_USE_EXTERNAL_SMESH=ON \
      -D BUILD_FLAT_MESH:BOOL=ON \
      -D BUILD_WITH_CONDA:BOOL=ON \
      ..

ninja -j${CPU_COUNT} install

rm ${PREFIX}/doc -r     # smaller size of package!
