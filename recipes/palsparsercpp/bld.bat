@echo on

:: AtomicAndPhysicalConstantsCLib: a static archive that is bundled into
:: PALSParserCpp.dll, as on the other platforms.
cmake %CMAKE_ARGS% -S apc -B build-apc -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DAPC_BUILD_TESTS=OFF
if errorlevel 1 exit 1
cmake --build build-apc --target apc
if errorlevel 1 exit 1

:: rapidyaml, PCRE2 and Catch2 come from the host environment; on Windows
:: rapidyaml and PCRE2 are DLLs in %LIBRARY_BIN%, which is on PATH while the
:: tests run.
cmake %CMAKE_ARGS% -S . -B build -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DPALS_USE_SYSTEM_DEPS=ON ^
    -DBUILD_TESTING=ON ^
    -DPALS_BUILD_EXAMPLES=OFF ^
    -DPALS_APC_INCLUDE_DIR="%SRC_DIR%\apc\include" ^
    -DPALS_APC_LIBRARY="%SRC_DIR%\build-apc\apc.lib"
if errorlevel 1 exit 1
cmake --build build
if errorlevel 1 exit 1

ctest --test-dir build --output-on-failure
if errorlevel 1 exit 1

:: The DLL (into Library\bin), its import library, its C header and its
:: license; no tests, examples or dependencies.
cmake --install build --component PALSParserCpp
if errorlevel 1 exit 1
