#!/usr/bin/env bash
set -eux
# --repository_cache="" disables the repository cache. The repository cache won't be
# cleaned by `bazel clean --expunge`, thus would leave trace.
python_version=${1:-${PY_VER}}
bazel build --repository_cache="" --config="py${python_version}" //:wheel
pip install --no-dependencies "$(bazel info bazel-bin)"/dist/*.whl
# We need to remove all the bazel's output because `conda build` looks at the diff of
# the working environment before and after running this script. And bazel's output
# are included in that working environment.
bazel clean --expunge
