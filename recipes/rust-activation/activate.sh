#!/usr/bin/env bash

export CARGO_HOME=${CONDA_PREFIX}/.cargo.$(uname)
export CARGO_CONFIG=${CARGO_HOME}/config
export RUSTUP_HOME=${CARGO_HOME}/rustup

[[ -d ${CARGO_HOME} ]] || mkdir -p ${CARGO_HOME}

export CARGO_TARGET_@rust_arch_env@_LINKER=${CC:-${CONDA_PREFIX}/bin/@rust_cc@}
export CARGO_BUILD_TARGET=@rust_arch@

if [[ "@cross_target_platfom@" == linux*  ]]; then
  export CARGO_BUILD_RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${PREFIX:-${CONDA_PREFIX}}/lib -C link-arg=-Wl,-rpath,${PREFIX:-${CONDA_PREFIX}}/lib"
elif [[ "@cross_target_platfom@" == osx* ]]; then
  export CARGO_BUILD_RUSTFLAGS="-C link-arg=-Wl,-rpath,${PREFIX:-${CONDA_PREFIX}}/lib"
fi

export PATH=${CARGO_HOME}/bin:${PATH}
