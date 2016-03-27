cc -I $PREFIX/include -L $PREFIX/lib test.c -lgmp -Wl,-rpath,$PREFIX/lib -o test.out
./test.out
