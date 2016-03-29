g++ $RECIPE_DIR/test.cpp -I$PREFIX/include  -L$PREFIX/lib -o test
[ $(./test) != "$PKG_VERSION" ] && exit 1

[ $(python -c 'import cv2; print(cv2.__version__)') != "$PKG_VERSION" ] && exit 1

