mkdir build -p
cd build 

cmake -D CMAKE_BUILD_TYPE:STRING=Release \
      -D CMAKE_PREFIX_PATH:FILEPATH=${PREFIX} \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=${PREFIX} \
      ..

make install

cd ..

${PYTHON} setup.py clean
${PYTHON} setup.py install