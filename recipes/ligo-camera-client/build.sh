#!/bin/bash

set -ex

export INSTALL_ROOT="${PREFIX}"

qmake
make
make install

