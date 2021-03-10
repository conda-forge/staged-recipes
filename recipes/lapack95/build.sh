cp $RECIPE_DIR/make.inc .
 
cd SRC/
make single_double_complex_dcomplex

echo "************** Starting copy of files. **************"

cp $RECIPE_DIR/lapack95.a $PREFIX/lib/liblapack95.a
cp $RECIPE_DIR/lapack95_modules/*.mod $PREFIX/include/
cd $PREFIX/include/
ln -s f95_lapack.mod lapack95.mod
