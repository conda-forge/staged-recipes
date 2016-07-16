cd %RECIPE_DIR%/..

mkdir build
cd build

:: Override cmake generator to visual studio 2015
if "%ARCH%" == "32" set CMAKE_GENERATOR=Visual Studio 14
if "%ARCH%" == "64" set CMAKE_GENERATOR=Visual Studio 14 Win64

:: Do parallel builds everywhere except AppVeyor
if not "%APPVEYOR%" == "True" (set ADDITIONAL_FLAGS="-MP") else (set ADDITIONAL_FLAGS="")

:: Configure step
cmake -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE=Release -DDYND_INSTALL_LIB=ON -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% -DCMAKE_CXX_FLAGS=%ADDITIONAL_FLAGS% .. || exit /b 1

:: Build step
cmake --build . --config Release || exit /b 1

:: Install step
cmake --build . --config Release --target install || exit /b 1
