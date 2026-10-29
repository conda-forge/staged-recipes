@echo on

:: OpenMVS loads vcpkg's toolchain whenever VCPKG_ROOT is set (as on the CI
:: images); build against the conda environment instead.
set "VCPKG_ROOT="

:: Windows: OpenMVS 2.4.0 has no shared libraries with MSVC, so (unlike on
:: Linux/macOS) the module is built in-tree with upstream's Python support,
:: linking OpenMVS's libraries statically into pyOpenMVS.
cmake -S . -B build-py -G Ninja %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DVCG_DIR=%PREFIX%\include\vcglib ^
  -DPython3_EXECUTABLE=%PYTHON% ^
  -DOpenMVS_USE_CUDA=OFF ^
  -DOpenMVS_USE_PYTHON=ON ^
  -DOpenMVS_BUILD_TOOLS=OFF ^
  -DOpenMVS_BUILD_VIEWER=OFF ^
  -DOpenMVS_USE_BREAKPAD=OFF ^
  -DOpenMVS_ENABLE_TESTS=OFF ^
  -DOpenMVS_ENABLE_IPO=OFF ^
  -DENABLE_SSE3=OFF -DENABLE_SSSE3=OFF -DENABLE_SSE41=OFF -DENABLE_SSE42=OFF ^
  -DENABLE_AVX=OFF -DENABLE_AVX2=OFF
if errorlevel 1 exit 1

cmake --build build-py --parallel %CPU_COUNT% --target pyOpenMVS
if errorlevel 1 exit 1

:: The target is a DLL named pyOpenMVS.dll; Python imports it as a .pyd
for /r build-py %%f in (pyOpenMVS.dll) do if exist "%%f" copy /y "%%f" "%SP_DIR%\pyOpenMVS.pyd"
if not exist "%SP_DIR%\pyOpenMVS.pyd" exit 1
