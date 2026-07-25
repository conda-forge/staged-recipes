#!/usr/bin/env bash
set -euxo pipefail

dump_cmake_logs() {
	echo "CMake configure failed; dumping logs for diagnostics" >&2
	cat build-conda/CMakeFiles/CMakeError.log || true
	cat build-conda/CMakeFiles/CMakeOutput.log || true
}

report_failure() {
	local line_number="${1:-unknown}"
	local failing_command="${2:-unknown}"
	echo "build.sh failed at line ${line_number}: ${failing_command}" >&2
	dump_cmake_logs
}

trap 'report_failure "${LINENO}" "${BASH_COMMAND}"' ERR

echo "build.sh: target_platform=${target_platform:-unset}" >&2
echo "build.sh: PREFIX=${PREFIX:-unset}" >&2
echo "build.sh: SRC_DIR=${SRC_DIR:-unset}" >&2

mkdir -p build-conda

# Conda source staging may drop executable bits from vendored host tools.
# Restore them so CMake/NASM invocations do not fail with permission errors.
for tool in \
	"$SRC_DIR/tools/host/nasm/linux/nasm" \
	"$SRC_DIR/tools/host/nasm/macosx/nasm" \
	"$SRC_DIR/tools/host/ninja/linux/ninja" \
	"$SRC_DIR/tools/host/ninja/linux-aarch64/ninja" \
	"$SRC_DIR/tools/host/ninja/mac/ninja"; do
	if [ -f "$tool" ]; then
		chmod +x "$tool"
	fi
done

cmake_openmp_args=()
if [[ "${target_platform:-}" == osx-* ]]; then
	# In conda-forge macOS builds, libomp comes from llvm-openmp in the prefix.
	cmake_openmp_args+=("-DOpenMP_ROOT=${PREFIX}")
fi

cmake_tool_args=()
if command -v nasm >/dev/null 2>&1; then
	# Force conda-forge NASM toolchain binary to avoid host-glibc mismatches
	# with vendored NASM executables shipped in source archives.
	cmake_tool_args+=("-DSPRING_NASM_EXECUTABLE=$(command -v nasm)")
fi

configure_log="build-conda/cmake-configure.log"

cmake \
	${CMAKE_ARGS} \
	-S . -B build-conda -G Ninja \
	-DSPRING_ENABLE_COMPILER_CACHE=OFF \
	${cmake_openmp_args[@]+"${cmake_openmp_args[@]}"} \
	${cmake_tool_args[@]+"${cmake_tool_args[@]}"} \
	2>&1 | tee "${configure_log}"
configure_status=${PIPESTATUS[0]}
if [[ ${configure_status} -ne 0 ]]; then
	dump_cmake_logs
	echo "----- begin cmake-configure.log -----" >&2
	cat "${configure_log}" >&2 || true
	echo "----- end cmake-configure.log -----" >&2
	exit 1
fi

build_jobs="${CPU_COUNT:-2}"
if [[ -z "${build_jobs}" || "${build_jobs}" -lt 1 ]]; then
	build_jobs=2
fi

echo "build.sh: using ${build_jobs} parallel build jobs" >&2
cmake --build build-conda --parallel "${build_jobs}"
cmake --install build-conda
