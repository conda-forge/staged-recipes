#!/bin/sh

mkdir -p test/build
cmake -S test -B test/build -G "Ninja"
cmake --build test/build --target all
