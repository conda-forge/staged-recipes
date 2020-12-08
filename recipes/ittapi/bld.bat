SETLOCAL EnableDelayedExpansion

pushd "%SRC_DIR%" || exit /b !ERRORLEVEL!

mkdir build-%c_compiler%
cd build-%c_compiler%

:: Configure.
cmake -G "NMake Makefiles"              ^
      -DCMAKE_BUILD_TYPE=Release        ^
      %SRC_DIR% || exit /b !ERRORLEVEL!

:: Build.
cmake --build . || exit /b !ERRORLEVEL!

:: Install the bits manually
copy /b /y bin\libittnotify.lib %LIBRARY_LIB% || exit /b !ERRORLEVEL!
copy /b /y %SRC_DIR%\include\ittnotify.h %LIBRARY_INC% || exit /b !ERRORLEVEL!
copy /b /y %SRC_DIR%\include\jitprofiling.h %LIBRARY_INC% || exit /b !ERRORLEVEL!
copy /b /y %SRC_DIR%\include\libittnotify.h %LIBRARY_INC% || exit /b !ERRORLEVEL!

popd
