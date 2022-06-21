#!/bin/bash

target=${PREFIX}/opt/snap
mkdir -p $target/.snap
mkdir -p ${PREFIX}/opt/snap-src

cp -r $SRC_DIR/* ${PREFIX}/opt/snap-src



