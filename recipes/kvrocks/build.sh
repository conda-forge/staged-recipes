cp $RECIPE_DIR/gcc $PREFIX/bin/gcc
chmod +x $PREFIX/bin/gcc

./x.py build -DENABLE_LUAJIT=OFF -DENABLE_OPENSSL=ON 

