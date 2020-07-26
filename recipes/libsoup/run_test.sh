set -ex

export G_MESSAGES_DEBUG=all

if test "$GIO_MODULE_DIR" != "" ; then
	unset GIO_MODULE_DIR
fi 

$CC ${LDFLAGS} -o test $RECIPE_DIR/test.c $(pkg-config --cflags --libs libsoup-2.4)
./test
