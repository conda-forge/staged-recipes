#!/bin/bash
set -e
${PREFIX}/bin/python setup.py build
${PREFIX}/bin/python setup.py install
