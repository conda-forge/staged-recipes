#!/bin/bash

set -euxo pipefail

if [[ $target_platform =~ osx.* ]]; then
    CLANG="$CC_FOR_BUILD" source gen-bazel-toolchain
    # SDK's curl gets in the way
    if [[ -d "$CONDA_BUILD_SYSROOT/usr/include/curl" ]]; then
        mv "$CONDA_BUILD_SYSROOT/usr/include/curl" "$CONDA_BUILD_SYSROOT/usr/include/curl.do-not-use"
    fi
else
    source gen-bazel-toolchain
fi

system_libs="com_google_boringssl"
system_libs+=",org_sourceware_bzip2"
system_libs+=",org_blosc_cblosc"
system_libs+=",se_curl"
system_libs+=",jpeg"
system_libs+=",png"
system_libs+=",org_lz4"
system_libs+=",org_tukaani_xz"
system_libs+=",net_zlib"
system_libs+=",com_github_pybind_pybind11"
system_libs+=",com_github_nlohmann_json"
system_libs+=",org_aomedia_avif"
# system_libs+=",com_google_absl"
export TENSORSTORE_SYSTEM_LIBS="$system_libs"

build_options=""
build_options+=" --crosstool_top=//bazel_toolchain:toolchain"
build_options+=" --logging=6"
build_options+=" --verbose_failures"
build_options+=" --toolchain_resolution_debug"
build_options+=" --local_cpu_resources=${CPU_COUNT}"
build_options+=" --subcommands"  # comment out for debugging
export TENSORSTORE_BAZEL_BUILD_OPTIONS="$build_options"

# TODO: figure out why we need both TENSORSTORE_BAZEL_BUILD_OPTIONS and a bazelrc
cat > .bazelrc <<EOF
build --crosstool_top=//custom_toolchain:toolchain
build --logging=6
build --verbose_failures
build --local_cpu_resources=${CPU_COUNT}
EOF

# replace bundled baselisk with a simpler forwarder to our own bazel in build prefix
export BAZEL_EXE="${BUILD_PREFIX}/bin/bazel"
export TENSORSTORE_BAZELISK="${RECIPE_DIR}/bazelisk_shim.py"

${PYTHON} -m pip install . -vv

# Save vendored licenses
mkdir -p licenses
ls bazel-work/external/
cp bazel-work/external/com_google_absl/LICENSE "${SRC_DIR}/licenses/com_google_absl.txt"
cp bazel-work/external/com_google_re2/LICENSE "${SRC_DIR}/licenses/com_google_re2.txt"
cp bazel-work/external/com_google_riegeli/LICENSE "${SRC_DIR}/licenses/com_google_riegeli.txt"
cp bazel-work/external/net_sourceforge_half/LICENSE.txt "${SRC_DIR}/licenses/net_sourceforge_half.txt"

# Clean up a bit to speed-up prefix post-processing
bazel clean || true
bazel shutdown || true
