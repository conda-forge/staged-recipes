#!/bin/bash

ls -d $PREFIX/*
mkdir -p "$PREFIX/bin"

echo $SRC_DIR
ls -d $PWD/*

cp ./msms.*.$PKG_VERSION $PREFIX/bin/msms
