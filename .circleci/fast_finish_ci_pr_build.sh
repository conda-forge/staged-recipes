#!/bin/bash

curl https://raw.githubusercontent.com/conda-forge/conda-forge-ci-setup-feedstock/branch2.0/recipe/conda_forge_ci_setup/ff_ci_pr_build.py | \
     python - -v --ci "circle" "${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}" "${CIRCLE_BUILD_NUM}" "${CIRCLE_PR_NUMBER}"
