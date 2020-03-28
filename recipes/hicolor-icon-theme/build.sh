#!/bin/bash

set -ex

./configure --prefix=$PREFIX
make install
