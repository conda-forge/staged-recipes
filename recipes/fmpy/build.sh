#!/bin/bash

WHL_FILE=https://pypi.python.org/packages/5b/10/a055c4dbe7e63336af68840b71452dd09224f8b6e2ed3d5a44f181b146e1/FMPy-${PKG_VERSION}-py2.py3-none-any.whl

pip install --no-deps ${WHL_FILE}
