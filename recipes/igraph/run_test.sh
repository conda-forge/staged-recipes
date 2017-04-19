#!/usr/bin/env bash
system=$(uname -s)

case $system in
	"Linux" )
		gcc igraph_test.c $(pkg-config --libs --cflags igraph) -o igraph_test
		./igraph_test
		;;
esac
