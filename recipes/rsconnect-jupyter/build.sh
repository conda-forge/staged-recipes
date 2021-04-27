#!/bin/sh
set -e

name="rsconnect-jupyter"
version="1.4.1"

echo version=\"$version\" > rsconnect_jupyter/version.py
echo {\"version\":\"$version\"} > rsconnect_jupyter/static/version.json
$PYTHON -m pip install . --no-deps -vv
