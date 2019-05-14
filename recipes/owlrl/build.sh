#!/usr/bin/env bash
cd dist
cp scripts/owlrl.py owlrl/_cli.py
python -m pip install . --no-deps -vv
