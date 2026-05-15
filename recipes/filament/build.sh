#!/usr/bin/env bash
set -euxo pipefail

cmake_options=(
  ${CMAKE_ARGS}
  -G Ninja
  -S .
  -B build
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"
  -DDIST_DIR=.
  -DFILAMENT_BUILD_TESTING=OFF
  -DFILAMENT_ENABLE_LTO=OFF
  -DFILAMENT_SKIP_SAMPLES=ON
  -DFILAMENT_SKIP_SDL2=ON
  -DFILAMENT_SUPPORTS_WEBGPU=OFF
  -DFILAMENT_SUPPORTS_WEBP_TEXTURES=OFF
  -DUSE_STATIC_LIBCXX=OFF
)

if [[ "${target_platform}" == linux-* ]]; then
  cmake_options+=(
    -DFILAMENT_ENABLE_EXPERIMENTAL_GCC_SUPPORT=ON
    -DFILAMENT_SUPPORTS_EGL_ON_LINUX=ON
  )
fi

cmake "${cmake_options[@]}"
cmake --build build --parallel "${CPU_COUNT}" --target \
  backend \
  bluegl \
  bluevk \
  cmgen \
  diffimg \
  filabridge \
  filaflat \
  filament \
  filamesh \
  geometry \
  glslminifier \
  matc \
  matinfo \
  matedit \
  mipgen \
  normal-blending \
  resgen \
  roughness-prefilter \
  shaders \
  smol-v \
  specgen \
  specular-color \
  uberz \
  utils

install -d "${PREFIX}/bin" "${PREFIX}/docs" "${PREFIX}/include" "${PREFIX}/lib"

for tool in \
  cmgen \
  diffimg \
  filamesh \
  glslminifier \
  matc \
  matinfo \
  matedit \
  mipgen \
  normal-blending \
  resgen \
  roughness-prefilter \
  specgen \
  specular-color \
  uberz; do
  install -m 755 "build/tools/${tool}/${tool}" "${PREFIX}/bin/${tool}"
done

for header_dir in \
  filament/include/filament \
  filament/backend/include/backend \
  libs/filabridge/include/filament \
  libs/filaflat/include/filaflat \
  libs/geometry/include/geometry \
  libs/math/include/math \
  libs/utils/include/utils; do
  cp -R "${header_dir}" "${PREFIX}/include/"
done

for library in \
  filament \
  backend \
  bluegl \
  bluevk \
  filabridge \
  filaflat \
  geometry \
  shaders \
  smol-v \
  utils; do
  library_path="$(find build -type f -name "lib${library}.a" -print -quit)"
  test -n "${library_path}"
  install -m 644 "${library_path}" "${PREFIX}/lib/"
done

install -d "${PREFIX}/lib/cmake/Filament"
install -m 644 "${RECIPE_DIR}/FilamentConfig.cmake" "${PREFIX}/lib/cmake/Filament/FilamentConfig.cmake"

install -m 644 LICENSE README.md "${PREFIX}/"
install -m 644 tools/filamesh/README.md "${PREFIX}/docs/filamesh.md"
install -m 644 tools/matinfo/README.md "${PREFIX}/docs/matinfo.md"
install -m 644 tools/mipgen/README.md "${PREFIX}/docs/mipgen.md"
install -m 644 tools/normal-blending/README.md "${PREFIX}/docs/normal-blending.md"
install -m 644 tools/roughness-prefilter/README.md "${PREFIX}/docs/roughness-prefilter.md"
install -m 644 tools/specular-color/README.md "${PREFIX}/docs/specular-color.md"
