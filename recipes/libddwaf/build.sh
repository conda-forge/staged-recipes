set -e -x

# remove bundled dependencies
> third_party/CMakeLists.txt
rm -r src/vendor/{re2,utf8proc}

# other bundled dependencies:
# - fmt (patched to use custom namespace)
# - libinjection, lua-aho-corasick, radixlib

MY_CMAKE_ARGS=(
	${CMAKE_ARGS}
	-GNinja
	-DLIBDDWAF_BUILD_STATIC=OFF
	-DLIBDDWAF_TEST_COVERAGE=OFF

	-DCMAKE_BUILD_TYPE=Release
	-DLIBDDWAF_ENABLE_LTO=ON
)

cmake -S. -Bbuild "${MY_CMAKE_ARGS[@]}"
ninja -C build
ninja -C build test
ninja -C build install
