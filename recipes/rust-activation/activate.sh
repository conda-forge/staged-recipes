#!/usr/bin/env bash

export CARGO_HOME=${CONDA_PREFIX}/.cargo.$(uname)
export CARGO_CONFIG=${CARGO_HOME}/config
export RUSTUP_HOME=${CARGO_HOME}/rustup

[[ -d ${CARGO_HOME} ]] || mkdir -p ${CARGO_HOME}

if [[ $(uname) == Darwin ]]; then
  echo "You may want to add this to /etc/launchd.conf for VSCode"
  echo "..  but actually it seems to source ~/.bash_profile for you so maybe better to just export these vars there (and conda activate devenv)"
  echo "setenv RUSTUP_HOME ${RUSTUP_HOME}"
  echo "setenv CARGO_HOME ${CARGO_HOME}"
  echo "setenv CARGO_CONFIG ${CARGO_CONFIG}"
fi

echo "[target.x86_64-apple-darwin]" >> ${CARGO_CONFIG}
echo "linker = \"${CONDA_PREFIX}/bin/x86_64-apple-darwin13.4.0-clang\"" >> ${CARGO_CONFIG}
echo "[target.i686-unknown-linux-gnu]" >> ${CARGO_CONFIG}
echo "linker = \"${CONDA_PREFIX}/bin/i686-conda_cos6-linux-gnu-cc\"" >> ${CARGO_CONFIG}
echo "[target.x86_64-unknown-linux-gnu]" >> ${CARGO_CONFIG}
echo "linker = \"${CONDA_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-cc\"" >> ${CARGO_CONFIG}
echo "[target.'cfg(...)']" >> ${CARGO_CONFIG}
echo "rustflags = [\"-C\", \"link-flags=-Wl,-rpath-link=${CONDA_PREFIX}/lib,-rpath=${CONDA_PREFIX}/lib\", \"-C\", \"opt-level=z\"]" >> ${CARGO_CONFIG}


echo "[target.x86_64-apple-darwin13.4.0]" > ${CARGO_CONFIG}
echo "linker = \"${CONDA_PREFIX}/bin/x86_64-apple-darwin13.4.0-cc\"" >> ${CARGO_CONFIG}
echo "rustflags = [\"-C\", \"link-arg=-Wl,-rpath,${CONDA_PREFIX}/lib\", \"-C\", \"opt-level=z\"]" >> ${CARGO_CONFIG}
echo "[target.x86_64-apple-darwin]" >> ${CARGO_CONFIG}
echo "linker = \"${CONDA_PREFIX}/bin/x86_64-apple-darwin13.4.0-clang\"" >> ${CARGO_CONFIG}
echo "rustflags = [\"-C\", \"link-arg=-Wl,-rpath,${CONDA_PREFIX}/lib\", \"-C\", \"opt-level=z\"]" >> ${CARGO_CONFIG}
echo "[target.i686-unknown-linux-gnu]" >> ${CARGO_CONFIG}
echo "linker = \"${CONDA_PREFIX}/bin/i686-conda_cos6-linux-gnu-cc\"" >> ${CARGO_CONFIG}
# -static-libgcc not seem to work, not sure we should care (from an AD packaging perspective, just make it depend on libgcc-ng and be happy).
# echo "rustflags = [\"-C\", \"link-arg=-Wl,-rpath-link,${CONDA_PREFIX}/lib\", \"-C\", \"link-arg=-Wl,-rpath,${CONDA_PREFIX}/lib\", \"-C\", \"opt-level=s\", \"-C\", \"link-arg=-static-libgcc\"]" >> ${CARGO_CONFIG}
echo "rustflags = [\"-C\", \"link-arg=-Wl,-rpath-link,${CONDA_PREFIX}/lib\", \"-C\", \"link-arg=-Wl,-rpath,${CONDA_PREFIX}/lib\", \"-C\", \"opt-level=s\"]" >> ${CARGO_CONFIG}
echo "[target.x86_64-unknown-linux-gnu]" >> ${CARGO_CONFIG}
echo "linker = \"${CONDA_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-cc\"" >> ${CARGO_CONFIG}
echo "rustflags = [\"-C\", \"link-arg=-Wl,-rpath-link,${CONDA_PREFIX}/lib\", \"-C\", \"link-arg=-Wl,-rpath,${CONDA_PREFIX}/lib\", \"-C\", \"opt-level=s\"]" >> ${CARGO_CONFIG}
echo "# Not sure about this stuff:" >> ${CARGO_CONFIG}
echo "# [target.'cfg(...)']" >> ${CARGO_CONFIG}
echo "# [build]" >> ${CARGO_CONFIG}
echo "# rustflags = [\"-C\", \"link-arg=-Wl,-rpath,${CONDA_PREFIX}/lib\", \"-C\", \"opt-level=z\"]" >> ${CARGO_CONFIG}

export PATH=${CARGO_HOME}/bin:${PATH}
