#!/bin/bash

set -xe
export PYTHON_VERSION=$(${PYTHON} -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
export PYTHON_MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f1)
export PYTHON_MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f2)
export BAZEL_VERSION="7.2.1"
export OUTPUT_DIR="$(pwd)"
export SOURCE_DIR="."
export RUN_TESTS="true"
. "./grain/oss/runner_common.sh"

#build_and_test_grain
setup_env_vars_py "$PYTHON_MAJOR_VERSION" "$PYTHON_MINOR_VERSION"

function write_to_bazelrc() {
  echo "$1" >> .bazelrc
}

write_to_bazelrc "build --incompatible_default_to_explicit_init_py"
write_to_bazelrc "build --enable_platform_specific_config"
write_to_bazelrc "build:macos --linkopt=-Wl,-undefined,dynamic_lookup"
write_to_bazelrc "build:macos --host_linkopt=-Wl,-undefined,dynamic_lookup"
write_to_bazelrc "build --@rules_python//python/config_settings:python_version=${PYTHON_VERSION}"
write_to_bazelrc "build --cxxopt=-Wno-deprecated-declarations --host_cxxopt=-Wno-deprecated-declarations"
write_to_bazelrc "build --cxxopt=-Wno-parentheses --host_cxxopt=-Wno-parentheses"
write_to_bazelrc "build --cxxopt=-Wno-sign-compare --host_cxxopt=-Wno-sign-compare"
write_to_bazelrc "test --@rules_python//python/config_settings:python_version=${PYTHON_VERSION}"
write_to_bazelrc "test --action_env PYTHON_VERSION=${PYTHON_VERSION}"
write_to_bazelrc "test --test_timeout=300"
write_to_bazelrc "common --check_direct_dependencies=error"

bazel clean
bazel build ... --action_env PYTHON_BIN_PATH="${PYTHON_BIN}" --action_env MACOSX_DEPLOYMENT_TARGET='11.0'

# bazel test --verbose_failures --test_output=errors ... --action_env PYTHON_BIN_PATH="${PYTHON}"

DEST="${OUTPUT_DIR}"'/all_dist'
mkdir -p "${DEST}"

TMPDIR="$(mktemp -d -t tmp.XXXXXXXXXX)"
cp README.md "${TMPDIR}"
cp setup.py "${TMPDIR}"
cp pyproject.toml "${TMPDIR}"
cp LICENSE "${TMPDIR}"
rsync -avm -L --exclude="__pycache__/*" grain "${TMPDIR}"
rsync -avm -L  --include="*.so" --include="*_pb2.py" \
    --exclude="*.runfiles" --exclude="*_obj" --include="*/" --exclude="*" \
    bazel-bin/grain "${TMPDIR}"

previous_wd="$(pwd)"
cd "${TMPDIR}"
printf '%s : "=== Building wheel\n' "$(date)"
WHEEL_BLD_ARGS="${WHEEL_BLD_ARGS} bdist_wheel --python-tag py3${PYTHON_MINOR_VERSION}"
if [ "$(uname)" == "Darwin" ]; then
  WHEEL_BLD_ARGS="${WHEEL_BLD_ARGS} --plat-name macosx_11_0_$(uname -m)"
fi
$PYTHON setup.py $WHEEL_BLD_ARGS

cp 'dist/'*.whl "${DEST}"

printf '%s : "=== Listing wheel\n' "$(date)"
ls -lrt "${DEST}"/*.whl
cd "${previous_wd}"

printf '%s : "=== Output wheel file is in: %s\n' "$(date)" "${DEST}"

$PYTHON -m pip install ./all_dist/grain*.whl

#--find-links=./all_dist --pre grain

# $PYTHON_BIN -m pip install jax
# $PYTHON_BIN grain/_src/core/smoke_test_with_jax.py
# # TF is not available on Python 3.13 and above.
# if (( "${PYTHON_MINOR_VERSION}" < 13 )); then
#   $PYTHON_BIN -m pip install tensorflow
#   $PYTHON_BIN grain/_src/core/smoke_test_with_tf.py
# fi

#bash "${SOURCE_DIR}"'/grain/oss/build_whl.sh'
