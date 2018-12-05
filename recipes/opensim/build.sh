#!/bin/bash

# TODO: Dependencies should be separate packages...
mkdir opensim_dependencies_build
cd opensim_dependencies_build
cmake ../dependencies/ \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DCMAKE_BUILD_TYPE=Release \
      -DSUPERBUILD_docopt=OFF
make -j$CPU_COUNT
cd ..

# TODO remove:
# cp -r $PREFIX/BTK/lib/btk-0.4dev/* $PREFIX/lib/
# cp -r $PREFIX/simbody/libexec/simbody/* $PREFIX/bin/

# TODO: Tests are missing!
mkdir opensim_build
cd opensim_build
cmake ../ \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DCMAKE_BUILD_TYPE=Release \
      -DOPENSIM_DEPENDENCIES_DIR="$PREFIX" \
      -DBUILD_PYTHON_WRAPPING=ON \
      -DBUILD_JAVA_WRAPPING=OFF \
      -DOPENSIM_PYTHON_VERSION=3 \
      -DOPENSIM_PYTHON_STANDALONE=ON \
      -DOPENSIM_INSTALL_UNIX_FHS=ON \
      -DBUILD_API_ONLY=ON \
      -DOPENSIM_BUILD_INDIVIDUAL_APPS_DEFAULT=OFF \
      -DOPENSIM_COPY_DEPENDENCIES=OFF \
      -DWITH_BTK=ON
make -j$CPU_COUNT
make install
