@echo on

:: Build script for kdsingleapplication, auto-discovered by
:: rattler-build on Windows (build.sh is the unix counterpart).
:: Uses %CMAKE_ARGS% (cmd.exe expansion): it carries the
:: -DCMAKE_INSTALL_PREFIX and build-type flags set by rattler-build.
:: The ${CMAKE_ARGS} form only expands in bash and reaches CMake
:: unexpanded on Windows.

cmake -B build -G Ninja %CMAKE_ARGS% -DKDSingleApplication_QT6=ON -DKDSingleApplication_EXAMPLES=OFF -DKDSingleApplication_TESTS=OFF
if %ERRORLEVEL% neq 0 exit /b 1

cmake --build build
if %ERRORLEVEL% neq 0 exit /b 1

cmake --install build
if %ERRORLEVEL% neq 0 exit /b 1
