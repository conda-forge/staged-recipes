#!/bin/bash

${PYTHON} -m pip install . -vv \
    --no-deps \
    --no-index \
    --ignore-installed && \

    fetch_requirements.py -p "requirements.txt" -v