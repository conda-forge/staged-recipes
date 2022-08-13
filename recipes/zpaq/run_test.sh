#!/bin/bash

set -xe

# make check converted into a script for post-install
zpaq add archive.zpaq "$PREFIX"/bin/zpaq
zpaq extract archive.zpaq "$PREFIX"/bin/zpaq -to zpaq.new
cmp "$PREFIX"/bin/zpaq zpaq.new
rm archive.zpaq zpaq.new
