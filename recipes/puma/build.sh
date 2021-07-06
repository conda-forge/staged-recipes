# PuMA C++ library
cd install 

"$SRC_DIR"/cpp/src/createCMakeLists_src.sh
"$SRC_DIR"/cpp/test/createCMakeLists_test.sh

mkdir -p cmake-build-release
cd cmake-build-release
cmake -D CONDA_PREFIX=$BUILD_PREFIX \
      -D PREFIX=$PREFIX \
      "$SRC_DIR"/cpp
make -j
make install


# TexGen
if [ ! -d "./TexGen" ]; then
    git clone --single-branch --branch py3 https://github.com/fsemerar/TexGen.git
fi
cd TexGen
mkdir -p bin
cd bin

PY_VERSION="$(python -c 'import sys; print(sys.version_info[1])')"
PY_VERSION_M=$PY_VERSION
if [ $PYNUM -le 7 ]; then
    PY_VERSION_M=$PY_VERSIONm
fi

# compilation options
cmake -D BUILD_PYTHON_INTERFACE=ON \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D PYTHON_INCLUDE_DIR="$BUILD_PREFIX"/include/python3.$PY_VERSION_M \
      -D PYTHON_LIBRARY="$BUILD_PREFIX"/lib/libpython3.$PY_VERSION_M$SHLIB_EXT \
      -D PYTHON_SITEPACKAGES_DIR="$SP_DIR" \
      -D BUILD_GUI=OFF \
      -D BUILD_RENDERER=OFF \
      -D CMAKE_MACOSX_RPATH=ON \
      -D CMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
      -D CMAKE_INSTALL_RPATH="$PREFIX"/lib \
      -D BUILD_SHARED_LIBS=OFF \
      ..

make -j
make install


# PuMA GUI
cd "$SRC_DIR"/gui/build
qmake
make -j
make install
