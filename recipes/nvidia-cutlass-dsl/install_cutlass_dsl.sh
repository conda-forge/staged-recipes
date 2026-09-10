#!/bin/bash
set -ex

# conda-build's SP_DIR omits the free-threading ABI suffix, so it points at the
# wrong site-packages on 3.14t: https://github.com/conda/conda-build/issues/5563
python_abi_version="$("$PYTHON" -c "import sysconfig; print(sysconfig.get_config_var('LDVERSION'))")"
pydir="$SRC_DIR/python_packages/python${python_abi_version//./}"
export SP_DIR="$PREFIX/lib/python${python_abi_version}/site-packages"

ctk_major="${cuda_compiler_version%%.*}"
other_ctk_major=12
[[ "$ctk_major" == "12" ]] && other_ctk_major=13
dsl_root="$SP_DIR/nvidia_cutlass_dsl"

# Eventually we'll install cutlass and iket into this output's own host prefix (after python is present).
# Install into this output's own host prefix (after python is present).
#mkdir -p "$SP_DIR"
#cp -vrpd "$pydir"/. "$SP_DIR/"

# What's below is so that we mirror the wheel's layout for compatibililty for the wheel users
# Eventually we'll remove this and follow conda's layout
mkdir -p "$dsl_root/dsl_packages"
cp -vrpd "$pydir"/. "$dsl_root/dsl_packages/"
echo "nvidia_cutlass_dsl/dsl_packages" > "$SP_DIR/nvidia_cutlass_dsl_packages.pth"

# Since we are mimicing wheel layout for conda, lib/ and include/ appear in two
# places. Nothing is duplicated: every entry here links back to the canonical
# $PREFIX location
mkdir -p "$dsl_root/cu${ctk_major}/lib" "$dsl_root/cu${ctk_major}/include"
ln -srv "$PREFIX/lib/libcute_dsl_runtime.so" "$dsl_root/cu${ctk_major}/lib/libcute_dsl_runtime.so"
ln -srv "$PREFIX/lib/libcuda_dialect_runtime_static.a" "$dsl_root/cu${ctk_major}/lib/libcuda_dialect_runtime_static.a"
ln -srv "$PREFIX/include/CuteDSLRuntime.h" "$dsl_root/cu${ctk_major}/include/CuteDSLRuntime.h"

# Cross-compile link stubs target aarch64, so only the x86_64 archive ships them
if [[ -d "$PREFIX/lib/stubs" ]]; then
  ln -srv "$PREFIX/lib/stubs" "$dsl_root/cu${ctk_major}/lib/stubs"
fi

# cuda-version admits only one CUDA major version per environment, so the other
# cu<major> directory is always empty. conda cannot ship an empty directory, so
# writing the README is also what creates it.
mkdir -p "$dsl_root/cu${other_ctk_major}"
cat > "$dsl_root/cu${other_ctk_major}/README.txt" <<EOF
This folder is empty because you have installed the CTK ${ctk_major} variant.
Only one CUDA major version can be installed at a time, so
cu${ctk_major} holds the runtime library, the static library and the header, and
cu${other_ctk_major} holds nothing.

To use CUDA ${other_ctk_major} instead, create an environment that asks for it:

    conda install nvidia-cutlass-dsl "cuda-version=${other_ctk_major}"
EOF
