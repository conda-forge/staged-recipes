@echo on

:: OpenMVS loads vcpkg's toolchain whenever VCPKG_ROOT is set (as on the CI
:: images); build against the conda environment instead.
set "VCPKG_ROOT="

if "%cuda_compiler_version%"=="None" (
  set "CUDA_ARGS=-DOpenMVS_USE_CUDA=OFF"
) else (
  set "CUDA_ARGS=-DOpenMVS_USE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=all-major"
)

:: OpenMVS 2.4.0 does not support shared libraries on Windows (upstream added
:: that after 2.4.0, cdcseacave/openMVS#1262), so its internal libraries are
:: linked statically into the tools; only the tools are shipped.
:: vcglib and portable-file-dialogs are noarch: generic, so their headers are
:: in %PREFIX%\include rather than %LIBRARY_INC%.
cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DVCG_DIR=%PREFIX%\include\vcglib ^
  -DPORTABLE_FILE_DIALOGS_INCLUDE_DIRS=%PREFIX%\include ^
  %CUDA_ARGS% ^
  -DOpenMVS_USE_PYTHON=OFF ^
  -DOpenMVS_BUILD_VIEWER=ON ^
  -DOpenMVS_USE_BREAKPAD=OFF ^
  -DOpenMVS_ENABLE_TESTS=ON ^
  -DOpenMVS_ENABLE_IPO=OFF ^
  -DENABLE_SSE3=OFF -DENABLE_SSSE3=OFF -DENABLE_SSE41=OFF -DENABLE_SSE42=OFF ^
  -DENABLE_AVX=OFF -DENABLE_AVX2=OFF
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

:: Unit tests (the pipeline test needs downloaded data)
build\bin\Tests.exe 0
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1

:: Put the tools on PATH; drop the static libraries, headers and CMake config.
del /q "%LIBRARY_BIN%\OpenMVS\Tests.exe"
move /y "%LIBRARY_BIN%\OpenMVS\*.exe" "%LIBRARY_BIN%\"
if errorlevel 1 exit 1
rmdir /s /q "%LIBRARY_BIN%\OpenMVS"
if exist "%LIBRARY_LIB%\OpenMVS" rmdir /s /q "%LIBRARY_LIB%\OpenMVS"
if exist "%LIBRARY_INC%\OpenMVS" rmdir /s /q "%LIBRARY_INC%\OpenMVS"
if exist "%LIBRARY_LIB%\cmake\OpenMVS" rmdir /s /q "%LIBRARY_LIB%\cmake\OpenMVS"
