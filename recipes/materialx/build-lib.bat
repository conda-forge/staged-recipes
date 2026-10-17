@echo on

:: See build-lib.sh for the rationale behind the options.
cmake %CMAKE_ARGS% -G Ninja -S . -B build ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DMATERIALX_BUILD_SHARED_LIBS=ON ^
    -DMATERIALX_BUILD_PYTHON=OFF ^
    -DMATERIALX_BUILD_VIEWER=OFF ^
    -DMATERIALX_BUILD_GRAPH_EDITOR=OFF ^
    -DMATERIALX_BUILD_DOCS=OFF ^
    -DMATERIALX_BUILD_OIIO=OFF ^
    -DMATERIALX_BUILD_OCIO=OFF ^
    -DMATERIALX_BUILD_TESTS=ON ^
    -DMATERIALX_TEST_RENDER=OFF ^
    -DMATERIALX_BUILD_USE_CCACHE=OFF ^
    -DMATERIALX_INSTALL_RESOURCES=OFF ^
    -DMATERIALX_INSTALL_STDLIB_PATH=share/materialx/libraries
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest --test-dir build --output-on-failure --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1

:: Upstream installs its top-level docs into the prefix root.
for %%f in (CHANGELOG.md LICENSE README.md THIRD-PARTY.md) do del /q "%LIBRARY_PREFIX%\%%f"
