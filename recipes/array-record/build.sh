#!/bin/bash

set -exuo pipefail

# https://github.com/bazelbuild/bazel/issues/14355
# Remove or change when upgrading Bazel 5.4.0
rm -rf ${BUILD_PREFIX}/share/bazel/install/*

source gen-bazel-toolchain

export CROSSTOOL_TOP="//bazel_toolchain:toolchain"
if [[ "${target_platform}" == linux-* ]]; then
    export AUDITWHEEL_PLATFORM="manylinux2014_$(uname -m)"
fi

export PYTHON_BIN="${PYTHON}"
export PYTHON_VERSION="$(${PYTHON} -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")"

# Remove .bazelrc if it already exists
[ -e .bazelrc ] && rm -f .bazelrc
echo "build -c opt" >> .bazelrc
echo "build --cxxopt=-std=c++17" >> .bazelrc
echo "build --host_cxxopt=-std=c++17" >> .bazelrc
echo "build --experimental_repo_remote_exec" >> .bazelrc
echo "build --python_path=\"${PYTHON_BIN}\"" >> .bazelrc
echo "build --logging=6" >> .bazelrc
echo "build --verbose_failures" >> .bazelrc
echo "build --define=PREFIX=${PREFIX}" >> .bazelrc
echo "build --crosstool_top=${CROSSTOOL_TOP}" >> .bazelrc
echo "build --cpu=${TARGET_CPU}" >> .bazelrc
echo "test --crosstool_top=${CROSSTOOL_TOP}" >> .bazelrc
echo "test --cpu=${TARGET_CPU}" >> .bazelrc
echo "build --local_cpu_resources=${CPU_COUNT}"

bazel clean
bazel build ...
bazel test --verbose_failures --test_output=errors ...

DEST="./all_dist"

mkdir -p "${DEST}"
echo "=== destination directory: ${DEST}"

TMPDIR=$(mktemp -d -t tmp.XXXXXXXXXX)

echo $(date) : "=== Using tmpdir: ${TMPDIR}"
mkdir "${TMPDIR}/array_record"

echo $(date) : "=== Copy array_record files"

cp setup.py "${TMPDIR}"
cp LICENSE "${TMPDIR}"
rsync -avm -L  --exclude="bazel-*/" . "${TMPDIR}/array_record"
rsync -avm -L  --include="*.so" --include="*_pb2.py" \
--exclude="*.runfiles" --exclude="*_obj" --include="*/" --exclude="*" \
bazel-bin/cpp "${TMPDIR}/array_record"
rsync -avm -L  --include="*.so" --include="*_pb2.py" \
--exclude="*.runfiles" --exclude="*_obj" --include="*/" --exclude="*" \
bazel-bin/python "${TMPDIR}/array_record"

pushd ${TMPDIR}
echo $(date) : "=== Building wheel"
${PYTHON_BIN} setup.py bdist_wheel --python-tag py3${PYTHON_MINOR_VERSION}

if [ -n "${AUDITWHEEL_PLATFORM}" ]; then
echo $(date) : "=== Auditing wheel"
auditwheel repair --plat ${AUDITWHEEL_PLATFORM} -w dist dist/*.whl
fi

echo $(date) : "=== Listing wheel"
ls -lrt dist/*.whl
cp dist/*.whl "${DEST}"
popd

echo $(date) : "=== Output wheel file is in: ${DEST}"

${PYTHON} -m pip install -vv --no-deps --no-build-isolation ${DEST}/*.whl
