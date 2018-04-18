mkdir build -p
cd build 

cmake -G "Ninja"  \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D MEDFILE_INSTALL_DOC=OFF \
      -D MEDFILE_BUILD_PYTHON=ON \
      -D PYTHON_INSTALL_DIR:FILEPATH=${SP_DIR} \
      ..

ninja install