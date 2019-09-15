#!/bin/bash
set -e
${PYTHON} setup.py build
${PYTHON} setup.py install
