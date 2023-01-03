#!/bin/bash
set -ex

# NOTE(hadim): this is where rocksdb is installed
export AIM_DEP_DIR=$PREFIX

python -m pip install . -vv
