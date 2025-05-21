#!/usr/bin/env bash

set -ex

mkdir -p "${PREFIX}/bin"
cp gtest-parallel "${PREFIX}/bin"
cp gtest_parallel.py "${PREFIX}/bin"
