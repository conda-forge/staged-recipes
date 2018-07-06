#!/usr/bin/env bash
set -e

if [ ! -z ${LIBRARY_PREFIX+x} ]; then
  ./install.sh $LIBRAY_PREFIX
else
  ./install.sh $PREFIX
fi
