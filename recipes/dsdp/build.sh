#!/bin/bash

cp ${RECIPE_DIR}/CMakeLists.txt ${SRC_DIR}
cmake ${SRC_DIR} -DCMAKE_BUILD_TYPE=Release \
                    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
                    -DBUILD_SHARED_LIBS=ON

make install
