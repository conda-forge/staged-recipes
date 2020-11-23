#!/bin/bash
set -xe

cd python/
export SKIP_THIRDPARTY_INSTALL=1
"${PYTHON}" setup.py build
# bazel by default makes everything read-only,
# which leads to patchelf failing to fix rpath in binaries.
# find all ray binaries and make them writable
grep -lR ELF build/ | xargs chmod +w

# now install the thing so conda could pick it up
"${PYTHON}" setup.py install

# now clean everything up so subsequent builds (for potentially
# different Python version) do not stumble on some after-effects
"${PYTHON}" setup.py clean --all
bazel "--output_user_root=$SRC_DIR/../bazel-root" "--output_base=$SRC_DIR/../b-o" clean
bazel "--output_user_root=$SRC_DIR/../bazel-root" "--output_base=$SRC_DIR/../b-o" shutdown
rm -rf "$SRC_DIR/../b-o" "$SRC_DIR/../bazel-root"
