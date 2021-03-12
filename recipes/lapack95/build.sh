cp $RECIPE_DIR/make.inc .
 
cd SRC/
make single_double_complex_dcomplex

cd ../

mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib

if [[ "$target_platform" == linux-* ]]; then
  $FC  -shared -o liblapack95.so -Wl,--whole-archive lapack95.a -Wl,--no-whole-archive $PREFIX/lib/liblapack.so $PREFIX/lib/libblas.so
elif [[ "$target_platform" == osx-* ]]; then
  $FC -shared -o liblapack95.dylib -Wl,-all_load lapack95.a -Wl,-noall_load $PREFIX/lib/liblapack.dylib $PREFIX/lib/libblas.dylib
fi

cp liblapack95$SHLIB_EXT $PREFIX/lib/liblapack95$SHLIB_EXT
cp lapack95_modules/*.mod $PREFIX/include/
cd $PREFIX/include/
ln -s f95_lapack.mod lapack95.mod
