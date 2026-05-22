#!/bin/bash
set -euo pipefail

RUNFILES_DIR="${SRC_DIR}/python/runfiles"

cat > "${RUNFILES_DIR}/pyproject.toml" <<PYPROJECT
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[project]
name = "bazel-runfiles"
version = "${PKG_VERSION}"
requires-python = ">=3.7"

[tool.setuptools]
packages = ["runfiles"]

[tool.setuptools.package-dir]
runfiles = "."

[tool.setuptools.package-data]
runfiles = ["py.typed"]
PYPROJECT

${PYTHON} -m pip install --no-deps --no-build-isolation "${RUNFILES_DIR}" -vv
