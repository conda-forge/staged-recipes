#!/bin/bash
sed -i'' -e 's/setup_requires=\["pytest-runner"\],//g' setup.py
sed -i'' -e "s/tests_require=\['pytest'\],//g" setup.py
$PYTHON -m pip install . -vv
