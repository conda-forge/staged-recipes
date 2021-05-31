#!/bin/bash

pushd _build
set -ex

make -j ${CPU_COUNT} V=1 VERBOSE=1 install -C Triggers/trig
