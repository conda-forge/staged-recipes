cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D CMAKE_BUILD_TYPE=Release .\CMakeLists.txt

nmake
copy gtest.lib %LIBRARY_BIN%
copy gtest_main.lib %LIBRARY_BIN%
xcopy /S %SRC_DIR%\include\gtest %LIBRARY_INC%
