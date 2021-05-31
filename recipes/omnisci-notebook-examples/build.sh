#!/usr/bin/env bash

TARGET_DIR=${PREFIX}/opt/omnisci-examples/
mkdir -p ${TARGET_DIR}

cp -R . ${TARGET_DIR}

# remore .git if exists
rm -rf ${TARGET_DIR}/.git
