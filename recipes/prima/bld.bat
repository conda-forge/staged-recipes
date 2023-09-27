cmake -LAH -G Ninja -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" . || exit 1

cmake --build . --target install --parallel %CPU_COUNT% || exit 1

cmake --build . --target tests --parallel %CPU_COUNT% || exit 1

ctest -E "large|stress" --output-on-failure -j${CPU_COUNT} --timeout 1000 || exit 1
