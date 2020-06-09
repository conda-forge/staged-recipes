#!/bin/bash

mkdir -p "$PREFIX/bin"
ls -d $PWD/*
cp ./msms.*.$PKG_VERSION $PREFIX/bin/msms
