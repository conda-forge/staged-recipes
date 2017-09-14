#!/usr/bin/env bash


# ARCH is an argument to the Makefile.
# So we tweak ARCH to be as expected.
if [ "$ARCH" == "64" ]
then
    export ARCH="amd64"
elif [ "$ARCH" == "32" ]
then
    export ARCH="i387"
fi

# Set compiler to use to match the system.
if [ "$(uname)" == "Darwin" ]
then
    export USEGCC=0
    export USECLANG=1
elif [ "$(uname)" == "Linux" ]
then
    export USEGCC=1
    export USECLANG=0
fi

make
make install prefix="${PREFIX}/"
