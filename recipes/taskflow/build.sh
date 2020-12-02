#!/bin/bash
set -e

cmake $SRC_DIR \
      -DCMAKE_INSTALL_PREFIX=$PREFIX

make install
