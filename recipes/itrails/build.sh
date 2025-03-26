#!/bin/bash

# Explicitly set version for setuptools-scm (important!)
export SETUPTOOLS_SCM_PRETEND_VERSION="{{ version }}"

# Standard Python installation via pip
$PYTHON -m pip install . -vv
