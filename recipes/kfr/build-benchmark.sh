#!/usr/bin/env bash
set -euxo pipefail

cd fft-benchmark

# SINGLE (a list, with the recipe's patch) selects the libraries whose
# benchmark is built: the current KFR and FFTW from the host environment,
# and the bundled KissFFT.
cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  "-DSINGLE=kfr;fftw;kissfft"
cmake --build build --parallel "${CPU_COUNT}"

# The two previous generations of KFR, from their sources (KFR_SRC_DIR), to
# compare them with the current one. Their DFT only compiles with Clang, and
# relies on implicit conversions between vector types.
if [[ "${target_platform}" == osx-* ]]; then
  LEGACY_CC="${CC}"
  LEGACY_CXX="${CXX}"
else
  LEGACY_CC=clang
  LEGACY_CXX=clang++
fi
X86_ARGS=()
if [[ "${target_platform}" == *-64 ]]; then
  # every instruction set, selected at runtime, with SSE2 as the baseline
  X86_ARGS+=(-DKFR_ARCH=sse2 -DKFR_ENABLE_DFT_MULTIARCH=ON -DKFR_ENABLE_MULTIARCH=ON)
fi
for generation in 5 6; do
  CC="${LEGACY_CC}" CXX="${LEGACY_CXX}" CXXFLAGS="${CXXFLAGS} -flax-vector-conversions=all" \
    cmake -S . -B build-kfr${generation} -G Ninja ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="${LEGACY_CC}" -DCMAKE_CXX_COMPILER="${LEGACY_CXX}" \
    -DSINGLE=kfr -DKFR_LEGACY=ON -DKFR_SRC_DIR="${SRC_DIR}/kfr${generation}" \
    -DENABLE_TESTS=OFF -DENABLE_EXAMPLES=OFF -DKFR_ENABLE_CAPI_BUILD=OFF \
    "${X86_ARGS[@]}"
  cmake --build build-kfr${generation} --parallel "${CPU_COUNT}" \
    --target fft_benchmark_kfr-any src_benchmark_kfr-any
done

# upstream has no install step: the programs are left in the build directories
mkdir -p "${PREFIX}/bin" "${PREFIX}/share/kfrlib-benchmark"
for program in build/fft_benchmark_* build/src_benchmark_*; do
  if [[ -f "${program}" && -x "${program}" ]]; then
    install -m 755 "${program}" "${PREFIX}/bin/"
  fi
done
for generation in 5 6; do
  install -m 755 build-kfr${generation}/fft_benchmark_kfr-any "${PREFIX}/bin/fft_benchmark_kfr${generation}-any"
  install -m 755 build-kfr${generation}/src_benchmark_kfr-any "${PREFIX}/bin/src_benchmark_kfr${generation}-any"
done
cp plot.py spectrogram.py spectrum.py README.md "${PREFIX}/share/kfrlib-benchmark/"
cp -r plans "${PREFIX}/share/kfrlib-benchmark/"
