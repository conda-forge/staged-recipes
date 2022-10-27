set -e


if [[ "$target_platform" == "osx-64" ]]; then
    # https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi


cd test
cmake . -G "Ninja" -D CMAKE_BUILD_TYPE="Release"
cmake --build . --config Release
./hello_hpx
