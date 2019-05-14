#!/usr/bin/env bash
cp bin/pyshacl pyshacl/_cli.py
python -m pip install . --no-deps -vv
