#!/bin/bash
set -e -x

curl -sL -o sdk.zip "${TABLEAU_URL}"

if [[ "$(uname)" == "Darwin" ]]; then
  LIBNAME="libtableauhyperapi.dylib"
else
  LIBNAME="libtableauhyperapi.so"
fi

ACTUAL_SHA256=$(sha256sum sdk.zip | awk '{print $1}')
if [[ "${ACTUAL_SHA256}" != "${TABLEAU_SHA256}" ]]; then
  echo "sha256 mismatch for ${TABLEAU_URL}: expected ${TABLEAU_SHA256}, got ${ACTUAL_SHA256}" >&2
  exit 1
fi

unzip -q sdk.zip
SDK_DIR=$(find . -maxdepth 1 -type d -name "tableauhyperapi-cxx-*")

mkdir -p "${PREFIX}/include" "${PREFIX}/lib" "${PREFIX}/share/cmake"
cp -r "${SDK_DIR}/include/hyperapi" "${PREFIX}/include/"
cp -r "${SDK_DIR}/share/cmake/." "${PREFIX}/share/cmake/"
cp -r "${SDK_DIR}/lib/hyper" "${PREFIX}/lib/"
cp "${SDK_DIR}/lib/${LIBNAME}" "${PREFIX}/lib/"

cp "${SDK_DIR}/LICENSE" .
cp "${SDK_DIR}/NOTICES.txt" .
cp "${SDK_DIR}/HYPER_API_OSS_disclosure.txt" .
