#!/bin/bash

mkdir -p $PREFIX/bin/
make vcctl
cp ./_output/bin/vcctl $PREFIX/bin/
chmod +x $PREFIX/bin/vcctl