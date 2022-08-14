#!/bin/bash
echo "Add SKILL library"
mkdir -p "${PREFIX}/lib/skill/softworks"
cp -rf "softworks" \
       "${PREFIX}/lib/skill/"

echo ''
echo 'Build Python Package:'
echo 'flit build --format wheel'
flit build --format wheel
echo 'python -m pip install --no-deps dist/*.whl -vv'
python -m pip install --no-deps dist/*.whl -vv
