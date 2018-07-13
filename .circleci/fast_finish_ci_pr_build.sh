#!/bin/bash

curl https://raw.githubusercontent.com/conda-forge/conda-forge-ci-setup-feedstock/master/recipe/ff_ci_pr_build.py | \
     python - -v --ci "circle" "${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}" "${CIRCLE_BUILD_NUM}" "${CIRCLE_PR_NUMBER}"
