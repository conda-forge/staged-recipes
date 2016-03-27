cc -I $PREFIX/include -L $PREFIX/lib test.c -lmpir -Wl,-rpath,$PREFIX/lib -o test.out
./test.out
