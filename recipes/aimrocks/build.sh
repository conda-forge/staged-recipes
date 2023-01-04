#!/bin/bash
set -ex

# NOTE(hadim): to locate rocksdb
export AIM_DEP_DIR=$PREFIX

# Do not embed rocksdb in the package
export EMBED_ROCKSDB=0

python -m pip install . -vv
