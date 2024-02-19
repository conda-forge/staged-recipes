setlocal EnableDelayedExpansion
@echo on

rmdir /S /Q build

mkdir build
cd build

:: We install to a temp directory to avoid duplicate compilation for libsofa-core and
:: libsofa-core-devel. This is inspired from:
:: https://github.com/conda-forge/boost-feedstock/blob/main/recipe/meta.yaml
mkdir temp_prefix

:: Configure
cmake %CMAKE_ARGS% ^
  -B . ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DCMAKE_INSTALL_PREFIX:PATH=temp_prefix\ ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DSOFA_ENABLE_LEGACY_HEADERS:BOOL=OFF ^
  -DAPPLICATION_SOFAPHYSICSAPI=OFF ^
  -DSOFA_BUILD_SCENECREATOR=OFF ^
  -DSOFA_BUILD_TESTS=OFF ^
  -DSOFA_FLOATING_POINT_TYPE=double ^
  -DPLUGIN_CIMGPLUGIN=OFF ^
  -DPLUGIN_SOFAMATRIX=OFF ^
  -DPLUGIN_SOFADENSESOLVER=OFF ^
  -DPLUGIN_SOFAEXPORTER=OFF ^
  -DPLUGIN_SOFAHAPTICS=OFF ^
  -DPLUGIN_SOFAOPENGLVISUAL=OFF ^
  -DPLUGIN_SOFAPRECONDITIONER=OFF ^
  -DPLUGIN_SOFAVALIDATION=OFF ^
  -DPLUGIN_SOFA_GUI_QT=OFF ^
  -DSOFA_GUI_QT_ENABLE_QGLVIEWER=OFF ^
  -DSOFAGUI_QT=OFF ^
  -DSOFA_GUI_QT_ENABLE_QTVIEWER=OFF ^
  -DSOFAGUI_QGLVIEWER=OFF ^
  -DSOFAGUI_QTVIEWER=OFF ^
  -DSOFA_NO_OPENGL=ON ^
  -DSOFA_WITH_OPENGL=OFF ^
  -DPLUGIN_MULTITHREADING=ON ^
  -DAPPLICATION_RUNSOFA=OFF ^
  -DPLUGIN_ARTICULATEDSYSTEMPLUGIN=OFF ^
  -DSOFA_ALLOW_FETCH_DEPENDENCIES=OFF
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1

:: For Windows build, as we don't have rpath like in Unix systems to store
:: paths to internal Sofa plugins dynamic libraries and as each plugin is stored
:: into a separated folder, we have to copy all plugins libaries into the main 
:: Sofa binary folder. This should change in Sofa in future releases and will enable
:: to avoid this.
:: for /D %%f in ("%LIBRARY_PREFIX%\plugins\*") do copy "%%f\bin\*.dll" "%LIBRARY_BIN%"
echo %LIBRARY_PREFIX%
echo %LIBRARY_BIN%
for /D %%f in ("%LIBRARY_PREFIX%\plugins\*") do echo "%%f"
for /D %%f in ("%LIBRARY_PREFIX%\plugins\*") do copy "%%f\bin\*.dll" "%LIBRARY_BIN%"

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: Copy unix shell activation scripts, needed by Windows Bash users
    copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)

@echo off
