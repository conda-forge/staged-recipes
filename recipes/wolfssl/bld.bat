@echo on
setlocal EnableDelayedExpansion

mkdir build || exit 1
cd build || exit 1

:: The unit tests are behind WOLFSSL_EXAMPLES in CMakeLists.txt
:: upstream uses msbuild to do their CI
:: msbuild /m /p:PlatformToolset=v142 /p:Platform=x64 /p:Configuration=Release wolfssl64.sln

cmake -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
	  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
	  -DCMAKE_BUILD_TYPE=Release ^
	  -DWOLFSSL_REPRODUCIBLE_BUILD=yes ^
	  -DWOLFSSL_EXAMPLES=yes ^
	  .. || exit 1

cmake  --build . -j %CPU_COUNT% || exit 1

:: timeout running of the tests
:: 5 minutes should be more than long enough
ScriptRunner.exe -appvscript %RECIPE_DIR%\check.bat -appvScriptRunnerParameters -timeout=300

REM put the error check back in place for after ctest before merging
::if errorlevel 1 exit 1

cmake --build . --target install || exit 1
