cp $RECIPE_DIR/license.txt .

./configure --prefix=$PREFIX
make
make check
make install
