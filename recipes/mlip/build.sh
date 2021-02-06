#!/bin/bash
cd make
make mlp
mkdir -p ${PREFIX}/bin
cp mlp ${PREFIX}/bin
