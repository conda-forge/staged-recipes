#!/usr/bin/env bash

set -o errexit

cd build

cmake -DCOMPONENT=devel -P cmake_install.cmake
