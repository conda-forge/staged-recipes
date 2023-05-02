set -euxo pipefail

if [[ "$target_platform" =~ "linux" ]]; then
    LDFLAGS="-lrt ${LDFLAGS}"
fi

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake -S . -B build -G "Ninja" ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DMOLD_USE_SYSTEM_MIMALLOC=ON -DMOLD_USE_SYSTEM_TBB=ON -DMOLD_LTO=ON
cmake --build build --config Release --target install
