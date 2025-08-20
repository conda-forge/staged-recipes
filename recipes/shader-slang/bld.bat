cd shader-slang

cmake -Bbuild ^
    %CMAKE_ARGS% ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_INCLUDEDIR="include/slang" ^
    -DSLANG_ENABLE_PREBUILT_BINARIES=OFF ^
    -DSLANG_ENABLE_SLANG_GLSLANG=OFF ^
    -DSLANG_ENABLE_EXAMPLES=OFF ^
    -DSLANG_ENABLE_REPLAYER=OFF ^
    -DSLANG_ENABLE_GFX=OFF ^
    -DSLANG_ENABLE_TESTS=OFF ^
    -DSLANG_USE_SYSTEM_VULKAN_HEADERS=ON ^
    -DSLANG_USE_SYSTEM_SPIRV_HEADERS=ON ^
    -DSLANG_USE_SYSTEM_SPIRV_TOOLS=ON ^
    -DSLANG_ENABLE_SLANG_RHI=OFF ^
    -DSLANG_SLANG_LLVM_FLAVOR=DISABLE ^
    .
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1

exit 0
