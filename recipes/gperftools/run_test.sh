#!/bin/sh
gcc test_ltcmalloc.c -ltcmalloc -o test_ltcmalloc.o
./test_ltcmalloc.o
