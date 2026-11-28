#!/usr/bin/env bash
set -euxo pipefail

mkdir -p out/pylib/anki
# anki embeds the build hash into its version string
echo -n "${ANKI_TAG}" > out/buildhash

export PROTOC="${BUILD_PREFIX}/bin/protoc"
export PYO3_PYTHON="${PYTHON}"

if [[ "${target_platform}" == linux-* ]]; then
  features=rustls
else
  features=native-tls
fi

# builds the anki_i18n and anki_proto crates as well, which generate
# out/pylib/anki/_fluent.py and out/pylib/anki/_backend_generated.py
cargo auditable build --release --locked -p rsbridge --features "${features}"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

target_dir="target/${CARGO_BUILD_TARGET:-}/release"
if [[ "${target_platform}" == osx-* ]]; then
  cp "${target_dir}/librsbridge.dylib" out/pylib/anki/_rsbridge.so
else
  cp "${target_dir}/librsbridge.so" out/pylib/anki/_rsbridge.so
fi

protoc \
  --plugin=protoc-gen-mypy="${BUILD_PREFIX}/bin/protoc-gen-mypy" \
  --python_out=out/pylib \
  --mypy_out=out/pylib \
  -Iproto proto/anki/*.proto

(cd pylib/tools && PYTHONPATH=../anki/_vendor python genhooks.py ../../out/pylib/anki/hooks_gen.py)
python pylib/tools/genbuildinfo.py .version out/buildhash out/pylib/anki/buildinfo.py

# the hatch build hook only picks up the generated files when a tag is set
export ANKI_WHEEL_TAG=py3-none-any
${PYTHON} -m pip install ./pylib -vv --no-deps --no-build-isolation
