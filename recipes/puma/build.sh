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
