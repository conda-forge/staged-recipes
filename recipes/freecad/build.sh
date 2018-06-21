mkdir -p build
cd build

declare -a CMAKE_PLATFORM_FLAGS
if [ `uname` = "Darwin" ]; then

      sed -i '' 's/Xcode-9.app/Xcode.app/g' $PREFIX/lib/cmake/opencascade/OpenCASCADEVisualizationTargets.cmake
      CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
      SOME_VAR="-D BUILD_WEB:BOOL=OFF \
                -D BUILD_START:BOOL=OFF \
                -D BUILD_FEM_NETGEN=OFF \
                -D OCCT_CMAKE_FALLBACK:BOOL=OFF \
             "
else
      SOME_VAR="-D BUILD_WEB:BOOL=ON \
                -D BUILD_FEM_NETGEN:BOOL=ON \
                -D OCCT_CMAKE_FALLBACK:BOOL=OFF \
             "
fi

export LIBRARY_PATH=$PREFIX/lib

cmake -G "Ninja" \
      -D BUID_WITH_CONDA:BOOL=ON \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D CMAKE_PREFIX_PATH:FILEPATH=$PREFIX \
      -D CMAKE_LIBRARY_PATH:FILEPATH=$PREFIX/lib \
      -D CMAKE_INCLUDE_PATH:FILEPATH=$PREFIX/include \
      -D BUILD_QT5:BOOL=ON \
      -D FREECAD_USE_OCC_VARIANT="Official Version" \
      -D OCC_INCLUDE_DIR:FILEPATH=$PREFIX/include \
      -D USE_BOOST_PYTHON:BOOL=OFF \
      -D FREECAD_USE_PYBIND11:BOOL=ON \
      -D BUILD_ENABLE_CXX11:BOOL=ON \
      -D SMESH_INCLUDE_DIR:FILEPATH=$PREFIX/include/smesh \
      -D FREECAD_USE_EXTERNAL_SMESH=ON \
      -D BUILD_FLAT_MESH:BOOL=ON \
      -D BUILD_WITH_CONDA:BOOL=ON \
      -D PYTHON_EXECUTABLE:FILEPATH=$PREFIX/bin/python \
      ${SOME_VAR} \
      ${CMAKE_PLATFORM_FLAGS[@]} \
      ..

ninja install
if [ `uname` != "Darwin" ]; then
      rm ${PREFIX}/doc -r     # smaller size of package!
fi
