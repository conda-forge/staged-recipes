setlocal EnableDelayedExpansion

::Configure
cmake %CMAKE_ARGS% ^
  -B build ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DPython_EXECUTABLE:PATH="%PREFIX%\python.exe" ^
  -DSP3_PYTHON_PACKAGES_DIRECTORY:PATH="..\..\lib\site-packages" ^
  -DSP3_BUILD_TEST:BOOL=OFF
if errorlevel 1 exit 1

:: Build.
cmake --build build --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --install build
if errorlevel 1 exit 1

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
  if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
  copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
)

:: Patch the generated CMake files of some bindings modules
:: that points to wrong .lib / .pyd files. This is due to the fact that
:: SofaPython3 CMakeLists for these modules install twice their libraries (lib and pyd):
:: one install inside $PREFIX/Library/(lib|bin), one other on $PREFIX/Lib/site-packages.
:: Python needs the one in site-packages, but CMake config files points to the ones
:: in $PREFIX/Library/(lib|bin). As this could not be fixed upstream yet, we have
:: to patch them afterwards here

:: Patch SofaRuntime CMake targets
python %RECIPE_DIR%\scripts\replace_str_file.py %PREFIX%\Library\lib\cmake\SofaPython3\Bindings.SofaRuntimeTargets-release.cmake ^
  "\${_IMPORT_PREFIX}/(lib|bin)/SofaRuntime" ^
  "${_IMPORT_PREFIX}/lib/../../Lib/site-packages/SofaRuntime/SofaRuntime"
if errorlevel 1 exit 1

:: Patch SofaRuntime CMake targets
python %RECIPE_DIR%\scripts\replace_str_file.py %PREFIX%\Library\lib\cmake\SofaPython3\Bindings.SofaTypesTargets-release.cmake ^
  "\${_IMPORT_PREFIX}/(lib|bin)/SofaTypes" ^
  "${_IMPORT_PREFIX}/lib/../../Lib/site-packages/SofaTypes/SofaTypes"
if errorlevel 1 exit 1

:: Patch SofaGui CMake targets
python %RECIPE_DIR%\scripts\replace_str_file.py %PREFIX%\Library\lib\cmake\SofaPython3\Bindings.SofaGuiTargets-release.cmake ^
  "\${_IMPORT_PREFIX}/(lib|bin)/Gui" ^
  "${_IMPORT_PREFIX}/lib/../../Lib/site-packages/Sofa/Gui"
if errorlevel 1 exit 1

:: Patch SofaExporter CMake targets
python %RECIPE_DIR%\scripts\replace_str_file.py %PREFIX%\Library\lib\cmake\SofaPython3\Bindings.SofaExporterTargets-release.cmake ^
  "\${_IMPORT_PREFIX}/(lib|bin)/SofaExporter" ^
  "${_IMPORT_PREFIX}/lib/../../Lib/site-packages/SofaExporter"
if errorlevel 1 exit 1
