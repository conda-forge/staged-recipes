#!/bin/bash

$PYTHON setup.py install --curl-config=$PREFIX/bin/curl-config \
    --openssl-dir=$PREFIX

rm -rf $PREFIX/share
