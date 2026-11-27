@echo on

:: AtomicAndPhysicalConstantsCLib: a static archive that is bundled into
:: PALSParserCpp.dll, as on the other platforms. It is configured with the
:: Visual Studio generator, which the compiler activation makes CMake's
:: default, not with Ninja: on Windows its static `apc` and its shared
:: `apc_shared` both write apc.lib (a static library and an import library),
:: and Ninja refuses that ("multiple rules generate apc.lib"). Only `apc` is
:: built.
cmake %CMAKE_ARGS% -S apc -B build-apc -DAPC_BUILD_TESTS=OFF
if errorlevel 1 exit 1
cmake --build build-apc --config Release --target apc
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
    -DPALS_APC_LIBRARY="%SRC_DIR%\build-apc\Release\apc.lib"
if errorlevel 1 exit 1
cmake --build build
if errorlevel 1 exit 1

ctest --test-dir build --output-on-failure
if errorlevel 1 exit 1

:: The DLL (into Library\bin), its import library, its C header and its
:: license; no tests, examples or dependencies.
cmake --install build --component PALSParserCpp
if errorlevel 1 exit 1
