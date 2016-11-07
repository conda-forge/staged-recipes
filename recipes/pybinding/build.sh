#!/bin/bash
export PB_NATIVE_SIMD=OFF
${PYTHON} setup.py install --single-version-externally-managed --record record.txt;
