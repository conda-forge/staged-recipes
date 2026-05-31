@echo on
setlocal EnableExtensions EnableDelayedExpansion

REM Conda-forge style split-output build script for RigExpert Fobos SDR.
REM The package is still Windows/Radioconda-first; the recipe separates outputs
REM using conda-build file lists after this common install step.

set "REPO_ROOT=%SRC_DIR%"
set "INSTALL_PREFIX=%LIBRARY_PREFIX%"
if "%INSTALL_PREFIX%"=="" set "INSTALL_PREFIX=%PREFIX%\Library"

set "CONDA_PREFIX=%PREFIX%"
set "CMAKE_PREFIX_PATH=%INSTALL_PREFIX%;%PREFIX%"
set "PKG_CONFIG_PATH=%INSTALL_PREFIX%\lib\pkgconfig;%PREFIX%\Library\lib\pkgconfig;%PKG_CONFIG_PATH%"
set "PATH=%INSTALL_PREFIX%\bin;%PREFIX%\Scripts;%PREFIX%\Library\bin;%PATH%"
set "FOBOS_DIR=%INSTALL_PREFIX%"
set "FOBOS_SDR_DIR=%INSTALL_PREFIX%"

cd /d "%REPO_ROOT%"
if errorlevel 1 exit /b 1

echo === Repository root: %REPO_ROOT%
echo === Conda prefix:    %PREFIX%
echo === Library prefix:  %INSTALL_PREFIX%
echo === CMAKE_PREFIX_PATH: %CMAKE_PREFIX_PATH%

if not exist "%REPO_ROOT%\third_party\libfobos-regular\CMakeLists.txt" (
  echo ERROR: bundled Regular libfobos source snapshot is missing.
  exit /b 1
)

rmdir /S /Q "%REPO_ROOT%\build-conda-forge-libfobos" 2>nul
cmake -S "%REPO_ROOT%\third_party\libfobos-regular" -B "%REPO_ROOT%\build-conda-forge-libfobos" -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%"
if errorlevel 1 exit /b 1

cmake --build "%REPO_ROOT%\build-conda-forge-libfobos" --config Release
if errorlevel 1 exit /b 1

cmake --install "%REPO_ROOT%\build-conda-forge-libfobos" --component Unspecified
if errorlevel 1 exit /b 1

if not exist "%REPO_ROOT%\third_party\libfobos-sdr-agile\CMakeLists.txt" (
  echo ERROR: bundled Agile libfobos_sdr source snapshot is missing.
  exit /b 1
)

rmdir /S /Q "%REPO_ROOT%\build-conda-forge-agile" 2>nul
cmake -S "%REPO_ROOT%\third_party\libfobos-sdr-agile" -B "%REPO_ROOT%\build-conda-forge-agile" -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%"
if errorlevel 1 exit /b 1

cmake --build "%REPO_ROOT%\build-conda-forge-agile" --config Release
if errorlevel 1 exit /b 1

cmake --install "%REPO_ROOT%\build-conda-forge-agile" --component Unspecified
if errorlevel 1 exit /b 1

rmdir /S /Q "%REPO_ROOT%\build-conda-forge-soapy" 2>nul
cmake -S "%REPO_ROOT%" -B "%REPO_ROOT%\build-conda-forge-soapy" -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%" ^
  -DFOBOS_INSTALL_GRC_BLOCKS=ON ^
  -DFOBOS_INSTALL_EXAMPLES=ON ^
  -DFOBOS_INSTALL_TOOLS=ON ^
  -DFOBOS_INSTALL_DOCS=ON ^
  -DFOBOS_PACKAGE_BUILD_ID="conda-forge-style-split-output" ^
  -DLIBFOBOS_INCLUDE_DIRS="%INSTALL_PREFIX%\include" ^
  -DLIBFOBOS_LIBRARIES="%INSTALL_PREFIX%\lib\fobos.lib" ^
  -DLIBFOBOS_SDR_AGILE_INCLUDE_DIRS="%INSTALL_PREFIX%\include" ^
  -DLIBFOBOS_SDR_AGILE_LIBRARIES="%INSTALL_PREFIX%\lib\fobos_sdr.lib"
if errorlevel 1 exit /b 1

cmake --build "%REPO_ROOT%\build-conda-forge-soapy" --config Release
if errorlevel 1 exit /b 1

cmake --install "%REPO_ROOT%\build-conda-forge-soapy"
if errorlevel 1 exit /b 1

if exist "%INSTALL_PREFIX%\share\SoapyFobosSDR\tools\__pycache__" rmdir /S /Q "%INSTALL_PREFIX%\share\SoapyFobosSDR\tools\__pycache__"
if exist "%INSTALL_PREFIX%\share\SoapyFobosSDR\examples\__pycache__" rmdir /S /Q "%INSTALL_PREFIX%\share\SoapyFobosSDR\examples\__pycache__"

echo === Installed split-output candidate files ===
dir "%INSTALL_PREFIX%\bin\fobos*.dll"
dir "%INSTALL_PREFIX%\lib\fobos*.lib"
dir "%INSTALL_PREFIX%\share\SoapyFobosSDR" /S /B

exit /b 0
