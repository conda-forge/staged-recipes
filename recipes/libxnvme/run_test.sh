#!/usr/bin/env bash
#
# Test that the xNVMe CLI tool can run without error and the library pkg-config
# files can be utilized to locate the library
#
set -e
which xnvme
xnvme library-info
pkg-config xnvme --libs
