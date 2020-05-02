#!/bin/bash

mkdir -p ${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr
pushd ${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot > /dev/null 2>&1
  # Copy headers
  cp -R ${SRC_DIR}/rpm/* ./usr/

  popd > /dev/null 2>&1
