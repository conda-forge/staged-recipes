@echo on

if "%cuda_compiler_version%"=="None" (
  set "CUDA_ARGS=-DOpenMVS_USE_CUDA=OFF"
) else (
  set "CUDA_ARGS=-DOpenMVS_USE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=all-major"
)

:: vcglib and portable-file-dialogs are noarch: generic, so their headers are
:: in %PREFIX%\include rather than %LIBRARY_INC%.
cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SHARED_LIBS=ON ^
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
set "PATH=%CD%\build\bin;%PATH%"
build\bin\Tests.exe 0
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1

:: The tools and OpenMVS's DLLs (Common, IO, Math, MVS: generic names) stay in
:: Library\bin\OpenMVS, where Windows finds the DLLs next to the executables;
:: put small launchers on PATH.
del /q "%LIBRARY_BIN%\OpenMVS\Tests.exe"
for %%t in (DensifyPointCloud InterfaceCOLMAP InterfaceMetashape InterfaceMVSNet InterfacePolycam ReconstructMesh RefineMesh TextureMesh TransformScene Viewer) do (
  if not exist "%LIBRARY_BIN%\OpenMVS\%%t.exe" exit 1
  > "%LIBRARY_BIN%\%%t.bat" echo @"%%~dp0OpenMVS\%%t.exe" %%*
)

:: Upstream's CMake config does not find its dependencies; do not ship it.
if exist "%LIBRARY_LIB%\cmake\OpenMVS" rmdir /s /q "%LIBRARY_LIB%\cmake\OpenMVS"
