#!/bin/sh
gcc test.cc -o test.o -I$PREFIX/include && ./test.o
