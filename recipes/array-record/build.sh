#!/bin/bash

set -xe

export PYTHON_VERSION=$(${PYTHON} -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
export PYTHON_MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f1)
export PYTHON_MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f2)
export BAZEL_VERSION="7.2.1"
export OUTPUT_DIR="$(pwd)"
export SOURCE_DIR="."
. "./oss/runner_common.sh"

setup_env_vars_py "$PYTHON_MAJOR_VERSION" "$PYTHON_MINOR_VERSION"

function write_to_bazelrc() {
  echo "$1" >> .bazelrc
}

write_to_bazelrc "build -c opt"
write_to_bazelrc "build --cxxopt=-std=c++17"
write_to_bazelrc "build --host_cxxopt=-std=c++17"
write_to_bazelrc "build --experimental_repo_remote_exec"
write_to_bazelrc "build --python_path=\"${PYTHON_BIN}\""
write_to_bazelrc "build --incompatible_default_to_explicit_init_py"
write_to_bazelrc "build --enable_platform_specific_config"
write_to_bazelrc "build --@rules_python//python/config_settings:python_version=${PYTHON_VERSION}"
write_to_bazelrc "test --@rules_python//python/config_settings:python_version=${PYTHON_VERSION}"
write_to_bazelrc "test --action_env PYTHON_VERSION=${PYTHON_VERSION}"
write_to_bazelrc "test --test_timeout=300"
write_to_bazelrc "test --python_path=\"${PYTHON_BIN}\""
write_to_bazelrc "common --check_direct_dependencies=error"

export USE_BAZEL_VERSION="${BAZEL_VERSION}"
bazel clean
bazel build ... --action_env PYTHON_BIN_PATH="${PYTHON_BIN}"

DEST="${OUTPUT_DIR}"'/all_dist'
mkdir -p "${DEST}/array_record"

TMPDIR="$(mktemp -d -t tmp.XXXXXXXXXX)"
cp setup.py "${TMPDIR}"
cp LICENSE "${TMPDIR}"
rsync -avm -L  --exclude="bazel-*/" . "${TMPDIR}/array_record"
rsync -avm -L  --include="*.so" --include="*_pb2.py" \
  --exclude="*.runfiles" --exclude="*_obj" --include="*/" --exclude="*" \
  bazel-bin/cpp "${TMPDIR}/array_record"
rsync -avm -L  --include="*.so" --include="*_pb2.py" \
  --exclude="*.runfiles" --exclude="*_obj" --include="*/" --exclude="*" \
  bazel-bin/python "${TMPDIR}/array_record"

previous_wd="$(pwd)"
cd "${TMPDIR}"
printf '%s : === Building wheel\n' "$(date)"
$PYTHON setup.py bdist_wheel --python-tag py3"${PYTHON_MINOR_VERSION}"

cp dist/*.whl "${DEST}"

printf '%s : === Listing wheel\n' "$(date)"
ls -lrt "${DEST}"/*.whl
cd "${previous_wd}"

printf '%s : === Output wheel file is in: %s\n' "$(date)" "${DEST}"

$PYTHON -m pip install "${DEST}"/array_record*.whl
