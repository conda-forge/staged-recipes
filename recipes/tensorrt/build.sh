#!/usr/bin/env bash

set -euxo pipefail

case "${PKG_NAME}" in
  tensorrt-libs)
    tar --zstd -xf tensorrt.tar.zst --strip-components=1 --wildcards \
      '*/doc/README.txt' \
      '*/doc/Acknowledgements.txt'
    rm -f tensorrt.tar.zst
    exit 0
    ;;
  libnvinfer)
    files=(
      '*/lib/libnvinfer.so.*'
      '*/lib/libnvinfer_builder_resource_ptx.so.*'
      '*/lib/libnvinfer_builder_resource_sm*.so.*'
    )
    ;;
  libnvinfer-win-builder-resource)
    files=('*/lib/libnvinfer_builder_resource_win_*.so.*')
    ;;
  libnvinfer-dispatch)
    files=('*/lib/libnvinfer_dispatch.so.*')
    ;;
  libnvinfer-lean)
    files=('*/lib/libnvinfer_lean.so.*')
    ;;
  libnvinfer-plugin)
    files=('*/lib/libnvinfer_plugin.so.*')
    ;;
  libnvinfer-vc-plugin)
    files=('*/lib/libnvinfer_vc_plugin.so.*')
    ;;
  libnvonnxparser)
    files=('*/lib/libnvonnxparser.so.*')
    ;;
  *)
    echo "Unknown TensorRT output: ${PKG_NAME}" >&2
    exit 1
    ;;
esac

tar --zstd -xf tensorrt.tar.zst --strip-components=1 --wildcards \
  "${files[@]}" \
  '*/doc/README.txt' \
  '*/doc/Acknowledgements.txt'
rm -f tensorrt.tar.zst

check-glibc lib/*.so.*
mkdir -p "${PREFIX}/lib"
mv -v lib/*.so.* "${PREFIX}/lib/"
