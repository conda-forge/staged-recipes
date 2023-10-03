#!/usr/bin/env bash
"${PYTHON}" "${RECIPE_DIR}"/test_pkg.py core || "${PYTHON}" ./test_pkg.py core
