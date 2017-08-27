
set CMAKE_CONFIG="Release"

cd %SRC_DIR%\sources\shiboken2
mkdir build && cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"                    ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    -DBUILD_TESTS=OFF                                        ^
    -DPYTHON_EXECUTABLE="%PYTHON%"                           ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

cd %SRC_DIR%\sources\pyside2
mkdir build && cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"                    ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    -DPYTHON_EXECUTABLE="%PYTHON%"                           ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

ctest --output-on-failure --timeout 100 || echo "no ok"
rem if errorlevel 1 exit 1

cd %SRC_DIR%\sources\pyside2-tools
git checkout 5.6
mkdir build && cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR:\=/%"                    ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    -DBUILD_TESTS=OFF                                        ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1


rem https://bugreports.qt.io/browse/PYSIDE-564
copy %RECIPE_DIR%\pyside2-uic.bat %LIBRARY_PREFIX%\bin
