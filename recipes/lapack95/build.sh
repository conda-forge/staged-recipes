cp $RECIPE_DIR/make.inc .
 
cd SRC/
make single_double_complex_dcomplex

mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib

echo "***** DEBUG:"

echo "***** DEBUG: pwd"
pwd

echo "***** DEBUG: ls -lahtr"
ls -lahtr

echo "***** DEBUG: ls -lahtr ../"
ls -lahtr ../

echo "***** DEBUG: ls -lahtr PREFIX/include"
ls -lahtr $PREFIX/include/

echo "************** Starting copy of files. **************"

cp ../lapack95.a $PREFIX/lib/liblapack95.a
cp ../lapack95_modules/*.mod $PREFIX/include/
cd $PREFIX/include/
ln -s f95_lapack.mod lapack95.mod
