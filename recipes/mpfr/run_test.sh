cc -L$PREFIX/lib -I$PREFIX/include -lmpfr -lgmp -Wl,-rpath,$PREFIX/lib $RECIPE_DIR/test.c -o test.o
./test.o
