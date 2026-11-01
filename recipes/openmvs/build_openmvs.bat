@echo on

:: OpenMVS loads vcpkg's toolchain whenever VCPKG_ROOT is set (as on the CI
:: images); build against the conda environment instead.
set "VCPKG_ROOT="

:: tinygltf is a noarch: generic package, so its header is in %PREFIX%\include
:: rather than %LIBRARY_INC%
set "CXXFLAGS=%CXXFLAGS% /I%PREFIX%\include"

:: Bundled code that is not used: IBFS (research-only license, see
:: OpenMVS_USE_IBFS=OFF) and copies of tinyxml2, nlohmann/json and tinygltf
:: (from conda-forge instead).
if exist libs\Math\IBFS rmdir /s /q libs\Math\IBFS
del /q libs\IO\TinyXML2.cpp libs\IO\TinyXML2.h libs\IO\json.hpp libs\IO\tiny_gltf.h


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
  -DINSTALL_USE_SUBDIR=OFF ^
  -DOpenMVS_LIBRARY_NAME_PREFIX=OpenMVS ^
  -DOpenMVS_USE_IBFS=OFF ^
  -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=%SRC_DIR%\build\bin ^
  -DVCG_DIR=%PREFIX%\include\vcglib ^
  -DPORTABLE_FILE_DIALOGS_INCLUDE_DIRS=%PREFIX%\include ^
  %CUDA_ARGS% ^
  -DOpenMVS_USE_PYTHON=OFF ^
  -DOpenMVS_BUILD_VIEWER=ON ^
  -DVIEWER_NAME=OpenMVSViewer ^
  -DOpenMVS_USE_BREAKPAD=OFF ^
  -DOpenMVS_ENABLE_TESTS=ON ^
  -DOpenMVS_ENABLE_IPO=OFF ^
  -DENABLE_SSE3=OFF -DENABLE_SSSE3=OFF -DENABLE_SSE41=OFF -DENABLE_SSE42=OFF ^
  -DENABLE_AVX=OFF -DENABLE_AVX2=OFF
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

:: Unit tests (the pipeline test needs downloaded data). Upstream's default
:: build-tree output directory with MSVC is bin\vc17\x64; overridden above.
build\bin\Tests.exe 0
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1

:: Ship only the tools: drop the static libraries, headers and CMake config.
del /q "%LIBRARY_BIN%\Tests.exe"
del /q "%LIBRARY_LIB%\OpenMVS*.lib"
if exist "%LIBRARY_INC%\OpenMVS" rmdir /s /q "%LIBRARY_INC%\OpenMVS"
if exist "%LIBRARY_PREFIX%\CMake" del /q "%LIBRARY_PREFIX%\CMake\OpenMVS*.cmake"
