#!/bin/bash -e -x

## TODO: remove the following `unset` lines, once the following issue in `conda-build` is resolved:
##       <https://github.com/conda/conda-build/issues/2255>

unset REQUESTS_CA_BUNDLE
unset SSL_CERT_FILE

rustc --help
rustdoc --help
cargo --help

echo "#!/usr/bin/env bash"                         > ./cc
if [[ ${target_platform} =~ linux.* ]]; then
  echo "x86_64-conda_cos6-linux-gnu-cc \"\$@\""   >> ./cc
elif [[ ${target_platform} == osx-64 ]]; then
  echo "x86_64-apple-darwin13.4.0-clang \"\$@\""  >> ./cc
  export CONDA_BUILD_SYSROOT=/opt/MacOSX10.10.sdk
fi
cat cc
chmod +x cc

mkdir ~/tmp-cargo || true
CARGO_TARGET_DIR=~/tmp-cargo PATH="$PWD:$PATH" cargo install xsv --force -vv
