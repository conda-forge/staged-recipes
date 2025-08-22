#!/bin/bash
set -ex

mkdir -p $PREFIX/include/uapi
mkdir -p $PREFIX/include/linux
cp -r include/uapi/* $PREFIX/include/uapi/
cp -r include/linux/* $PREFIX/include/linux/
