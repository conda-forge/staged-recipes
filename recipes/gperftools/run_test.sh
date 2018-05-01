#!/bin/sh
gcc test.c -ltcmalloc_minimal -o test
./test
