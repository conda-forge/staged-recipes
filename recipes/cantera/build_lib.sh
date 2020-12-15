source $RECIPE_DIR/build_devel.sh
echo "****************************"
echo "DELETING files from devel except shared libraries"
echo "****************************"

rm -rf $PREFIX/share
rm -rf $PREFIX/include
rm -rf $PREFIX/bin
rm -rf $PREFIX/lib/pkg-config
rm -rf $PREFIX/lib/libcantera.a

if [[ "$target_platform" == osx-* ]]; then
  ${OTOOL:-otool} -L $PREFIX/lib/libcantera.dylib
fi
