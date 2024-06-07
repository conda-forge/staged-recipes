#!/bin/bash

export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"

source gen-bazel-toolchain
bazel build --crosstool_top=//bazel_toolchain:toolchain --cpu ${TARGET_CPU} -c opt --//bazel:use_local_flex_bison --linkopt=-lm //...

mkdir -p $PREFIX/bin
chmod a+w $PREFIX/bin

# List of executables to install
# pulled from https://github.com/chipsalliance/homebrew-verible/blob/main/Formula/verible.rb#L34-L44
executables=(
  "bazel-bin/verilog/tools/diff/verible-verilog-diff"
  "bazel-bin/verilog/tools/formatter/verible-verilog-format"
  "bazel-bin/verilog/tools/kythe/verible-verilog-kythe-extractor"
  "bazel-bin/verilog/tools/lint/verible-verilog-lint"
  "bazel-bin/verilog/tools/ls/verible-verilog-ls"
  "bazel-bin/verilog/tools/obfuscator/verible-verilog-obfuscate"
  "bazel-bin/verilog/tools/preprocessor/verible-verilog-preprocessor"
  "bazel-bin/verilog/tools/project/verible-verilog-project"
  "bazel-bin/verilog/tools/syntax/verible-verilog-syntax"
)

# Copy each executable to the $PREFIX/bin directory
for exe in "${executables[@]}"; do
  if [ -f "$SRC_DIR/$exe" ]; then
    cp "$SRC_DIR/$exe" "$PREFIX/bin/"
    chmod a+wx "$PREFIX/bin/$(basename $exe)"
    patchelf --set-rpath "$PREFIX/lib" "$PREFIX/bin/$(basename $exe)"
  else
    echo "Executable $exe not found, skipping."
  fi
done
