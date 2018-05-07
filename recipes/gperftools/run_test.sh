#!/bin/sh
gcc test_ltcmalloc.c -o test_ltcmalloc.o -ltcmalloc -lstdc++
./test_ltcmalloc.o
