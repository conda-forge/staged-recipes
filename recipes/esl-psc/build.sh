#!/usr/bin/env bash
set -euo pipefail

cargo build --release --manifest-path esl_psc_rs/Cargo.toml

BIN_PATH="$(find . -type f \
  \( \
    -path "./esl_psc_rs/target/release/esl-psc" -o \
    -path "./esl_psc_rs/target/*/release/esl-psc" -o \
    -path "./target/release/esl-psc" -o \
    -path "./target/*/release/esl-psc" \
  \) \
  | head -n 1)"
if [ -z "${BIN_PATH}" ]; then
  echo "could not find built binary esl-psc in expected target directories" >&2
  find . -type f | sed -n '1,200p' >&2
  exit 1
fi

install -d "${PREFIX}/bin"
install -m 0755 "${BIN_PATH}" "${PREFIX}/bin/esl-psc"

install -d "${SP_DIR}/esl_psc_cli"
cp -a esl_psc_cli/. "${SP_DIR}/esl_psc_cli/"

install -d "${SP_DIR}/gui/core"
install -m 0644 gui/__init__.py "${SP_DIR}/gui/__init__.py"
install -m 0644 gui/core/fast_scan.py "${SP_DIR}/gui/core/fast_scan.py"
install -m 0644 gui/core/fasta_io.py "${SP_DIR}/gui/core/fasta_io.py"
install -m 0644 gui/core/ancestral_reconstruction.py "${SP_DIR}/gui/core/ancestral_reconstruction.py"
