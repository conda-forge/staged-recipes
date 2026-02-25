@echo on
setlocal enabledelayedexpansion

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DKOMPUTE_OPT_INSTALL=ON ^
    -DKOMPUTE_OPT_USE_BUILT_IN_VULKAN_HEADER=OFF ^
    -DKOMPUTE_OPT_USE_BUILT_IN_FMT=OFF ^
    -DKOMPUTE_OPT_USE_BUILT_IN_SPDLOG=OFF ^
    -DKOMPUTE_OPT_USE_SPDLOG=OFF ^
    -DKOMPUTE_OPT_BUILD_PYTHON=ON ^
    -DKOMPUTE_OPT_USE_BUILT_IN_PYBIND11=OFF ^
    -DKOMPUTE_OPT_BUILD_TESTS=OFF ^
    -DKOMPUTE_OPT_BUILD_DOCS=OFF ^
    -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1

for /r build %%f in (kp*.pyd) do (
    if exist "%%f" copy "%%f" "%SP_DIR%\"
)
if errorlevel 1 exit 1
