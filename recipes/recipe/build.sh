#!/bin/bash
set -ex

cmake -H. -bbuild

cmake --build build --target install
