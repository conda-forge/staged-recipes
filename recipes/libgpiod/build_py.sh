#!/usr/bin/env bash

export LINK_SYSTEM_LIBGPIOD=1
pushd bindings/python
${PYTHON} -m pip install -vv --no-build-isolation --no-deps .
