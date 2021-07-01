set -ex

export G_MESSAGES_DEBUG=all


$CC ${LDFLAGS} -o test $RECIPE_DIR/test.c $(pkg-config --cflags --libs libpeas-1.0)
./test
