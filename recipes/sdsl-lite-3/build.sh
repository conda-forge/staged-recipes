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

$SRC_DIR/install.sh "$PREFIX"

# Remove Google Test from the package to avoid clashes
rm "$PREFIX/lib/libgtest.a" "$PREFIX/lib/libgtest_main.a" "$PREFIX/lib/libgmock.a" "$PREFIX/lib/libgmock_main.a"
rm -r "$PREFIX/include/gtest/" "$PREFIX/include/gmock/"

