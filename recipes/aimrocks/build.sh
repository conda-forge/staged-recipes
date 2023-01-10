#!/bin/bash
set -ex

# NOTE(hadim): to locate rocksdb
export AIM_DEP_DIR=$PREFIX

# Do not embed rocksdb in the package
export AIMROCKS_EMBED_ROCKSDB=0

# Link to compression libs as well
export AIMROCKS_LINK_LIBS="bz2,lz4,snappy,z,zstd"

python -m pip install . -vv
