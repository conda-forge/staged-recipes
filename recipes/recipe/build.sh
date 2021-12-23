#!/bin/bash
set -ex

cmake -H. -Bbuild

cmake --build build --target install
