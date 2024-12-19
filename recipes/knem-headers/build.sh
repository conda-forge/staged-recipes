#!/bin/bash

set -ex

mkdir -p $PREFIX/include

cp common/*.h $PREFIX/include
