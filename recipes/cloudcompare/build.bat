@echo on
:: bundled copies of libraries conda-forge provides (see the patches)
if exist libs\qCC_io\extern\shapelib rmdir /s /q libs\qCC_io\extern\shapelib

cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DOPTION_DEPLOY_QT=OFF ^
  -DOPTION_USE_SYSTEM_SHAPE_LIB=ON ^
  -DCCCORELIB_USE_SYSTEM_NANOFLANN=ON ^
  -DPLUGIN_IO_QE57=ON ^
  -DPLUGIN_IO_QE57_USE_SYSTEM_LIBE57FORMAT=ON ^
  -DCCCORELIB_USE_TBB=ON ^
  -DCCCORELIB_USE_CGAL=ON ^
  -DEIGEN_ROOT_DIR=%LIBRARY_INC%\eigen3 ^
  -DCC_USE_EIGEN=ON ^
  -DOPTION_BUILD_CCVIEWER=ON ^
  -DPLUGIN_IO_QCORE=ON ^
  -DPLUGIN_IO_QADDITIONAL=ON ^
  -DPLUGIN_IO_QLAS=ON ^
  -DPLUGIN_STANDARD_QM3C2=ON ^
  -DPLUGIN_GL_QEDL=ON ^
  -DPLUGIN_GL_QSSAO=ON
if errorlevel 1 exit 1
cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1
cmake --install build
if errorlevel 1 exit 1

:: The applications live in %LIBRARY_PREFIX%\CloudCompare and \ccViewer (with
:: their plugins and shaders); Qt and the other DLLs come from Library\bin.
:: qt.conf points Qt at the environment's plugins; launchers on PATH.
for %%a in (CloudCompare ccViewer) do (
  (
    echo [Paths]
    echo Prefix = ..
    echo Plugins = lib/qt6/plugins
    echo Translations = share/qt6/translations
  ) > "%LIBRARY_PREFIX%\%%a\qt.conf"
  (
    echo @echo off
    echo set "PATH=%%~dp0;%%PATH%%"
    echo "%%~dp0..\%%a\%%a.exe" %%*
  ) > "%LIBRARY_BIN%\%%a.bat"
)
