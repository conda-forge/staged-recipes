#!/bin/bash
rm tensorflow_lite_support/tools/pip_package/BUILD

$PYTHON tensorflow_lite_support/tools/pip_package/setup.py install
