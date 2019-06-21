mkdir build && cd build

# this disables linking to python DSO
if [ `uname` == Darwin ]; then
    export  LDFLAGS="$LDFLAGS  -Wl,-flat_namespace,-undefined,suppress"
fi

cmake -G "Ninja" \
 -D CMAKE_BUILD_TYPE:STRING=Release \
 -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
 -D CMAKE_PREFIX_PATH:FILEPATH=$PREFIX \
 -D CMAKE_SYSTEM_PREFIX_PATH:FILEPATH=$PREFIX \
 -D OCC_INCLUDE_DIR:FILEPATH=$PREFIX/include/opencascade \
 -D OCC_LIBRARY_DIR:FILEPATH=$PREFIX/lib \
 -D PYTHON_EXECUTABLE:FILEPATH=$PYTHON \
 -D COLLADA_SUPPORT:BOOL=OFF \
 -D BUILD_EXAMPLES:BOOL=OFF \
 -D BUILD_GEOMSERVER:BOOL=OFF \
 -D BUILD_CONVERT:BOOL=OFF \
 -D LIBXML2_INCLUDE_DIR:FILEPATH=$PREFIX/include/libxml2 \
 ../cmake

ninja install
