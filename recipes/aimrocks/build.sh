#!/bin/bash
set -ex

# NOTE(hadim): to locate rocksdb
export AIM_DEP_DIR=$PREFIX

python -m pip install . -vv
