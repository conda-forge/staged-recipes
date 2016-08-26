#!/usr/bin/env bash
gcc igraph_test.c $(pkg-config --libs --cflags igraph) -o igraph_test
./igraph_test
