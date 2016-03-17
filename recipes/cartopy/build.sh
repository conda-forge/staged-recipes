#!/bin/bash

rm -rf lib/cartopy/tests/mpl/baseline_images

${PYTHON} setup.py install --single-version-externally-managed  --record record.txt
