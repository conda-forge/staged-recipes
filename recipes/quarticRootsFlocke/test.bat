cmake -G "Ninja" -B build -S "%RECIPE_DIR%\test-link-quarticRootsFlocke" -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
build\test_linkage
