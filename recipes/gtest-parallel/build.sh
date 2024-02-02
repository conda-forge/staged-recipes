#!/usr/bin/env bash

set -ex

install -t "${PREFIX}/bin" \
        gtest-parallel \
        gtest_parallel.py \
        gtest_parallel_mocks.py \
        gtest_parallel_tests.py
