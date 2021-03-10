cp $RECIPE_DIR/make.inc .
 
cd SRC/
make single_double_complex_dcomplex

mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib

cp ../lapack95.a $PREFIX/lib/liblapack95.a
cp ../lapack95_modules/*.mod $PREFIX/include/
cd $PREFIX/include/
ln -s f95_lapack.mod lapack95.mod
