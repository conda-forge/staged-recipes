#!/bin/bash
sed -i -e "7s|.*|# |g" setup.py
sed -i -e "8s|.*|# |g" setup.py
sed -i -e "10s|.*|# |g" setup.py

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
