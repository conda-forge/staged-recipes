# Just used for building tests, not included in package
pushd $SRC_DIR/external/cereal
git submodule update --init --recursive
popd

# Just used for building tests, not included in package
pushd $SRC_DIR/external/googletest
git submodule update --init --recursive
popd

$SRC_DIR/install.sh "$PREFIX"

# Remove Google Test from the package to avoid clashes
rm "$PREFIX/lib/libgtest.a" "$PREFIX/lib/libgtest_main.a" "$PREFIX/lib/libgmock.a" "$PREFIX/lib/libgmock_main.a"
rm -r "$PREFIX/include/gtest/" "$PREFIX/include/gmock/"

