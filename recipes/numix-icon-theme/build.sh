#!/bin/bash

set -ex

# nothing more to do than copy Numix and Numix-Light to the right location
mkdir -p $PREFIX/share/icons
cp -r Numix $PREFIX/share/icons/
cp -r Numix-Light $PREFIX/share/icons/
