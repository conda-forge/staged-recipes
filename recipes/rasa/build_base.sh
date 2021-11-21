#!/bin/bash

${PYTHON} -m pip install . -vv \
    --no-deps \
    --no-index \
    --ignore-installed && \

    #${PYTHON} fetch_requirements.py -p "requirements.txt" -v
    echo -e "\n\tPACKAGE_REQUIREMENTS_SPEC = "${PACKAGE_REQUIREMENTS_SPEC}"\n" && \
    export PACKAGE_REQUIREMENTS_SPEC=$(${PYTHON} -m fetch_requirements.py -p "requirements.txt" -l -v -i 2) && \
          echo -e "\n\tPACKAGE_REQUIREMENTS_SPEC = "${PACKAGE_REQUIREMENTS_SPEC}"\n"