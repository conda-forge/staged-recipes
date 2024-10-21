# Just used for building tests, not included in package
pushd $SRC_DIR/external

rmdir googletest
git clone https://github.com/google/googletest.git googletest
pushd googletest
git checkout e2239ee6043f73722e7aa812a459f54a28552929
popd

rmdir cereal
git clone -b v1.2.2 https://github.com/USCiLab/cereal.git cereal

popd

# Builds and does some basic tests
$SRC_DIR/install.sh "$PREFIX"

# Install the header files
mkdir -p $PREFIX/include/sdsl
cp -a include $PREFIX
rm -f $PREFIX/include/sdsl/.gitignore

mkdir -p $PREFIX/lib/cmake/sdsl-lite
install -pm 644 sdsl-lite.pc.cmake $PREFIX/lib/cmake/sdsl-lite/


