@echo on

sed -i "s/if(NOT(MSVC OR XCODE))/if(NOT XCODE)/" CMakeLists.txt

cmake -S . -B build -G Ninja ^
    %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DUHDR_BUILD_EXAMPLES=OFF ^
    -DUHDR_BUILD_TESTS=OFF ^
    -DUHDR_BUILD_BENCHMARK=OFF ^
    -DUHDR_BUILD_FUZZERS=OFF ^
    -DUHDR_BUILD_DEPS=OFF ^
    -DUHDR_BUILD_JAVA=OFF ^
    -DUHDR_BUILD_PACKAGING=OFF ^
    -DUHDR_ENABLE_INSTALL=ON ^
    -DUHDR_ENABLE_INTRINSICS=ON ^
    -DUHDR_ENABLE_LOGS=OFF ^
    -DUHDR_ENABLE_GLES=OFF ^
    -DUHDR_ENABLE_WERROR=OFF ^
    -DUHDR_WRITE_ISO=ON ^
    -DUHDR_WRITE_XMP=OFF
if %ERRORLEVEL% neq 0 exit /b 1

cmake --build build --parallel %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit /b 1

cmake --install build
if %ERRORLEVEL% neq 0 exit /b 1
