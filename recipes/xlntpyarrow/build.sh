#!/bin/bash
set -ex

export ARROW_HOME=$PREFIX

cd python
$PYTHON setup.py \
        build_ext --build-type=Release \
        install --single-version-externally-managed --record=record.txt
