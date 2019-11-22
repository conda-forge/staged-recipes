cp $RECIPE_DIR/license.txt .

./configure --prefix=$PREFIX
make -j${CPU_COUNT}
make check
make install
