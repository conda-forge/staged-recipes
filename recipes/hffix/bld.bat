mkdir %LIBRARY_INC%
copy include\*.hpp %LIBRARY_INC%

REM need to fix the build system for tests to work on windows
REM set "CXXFLAGS=%CXXFLAGS% -EHsc -MD"
REM make test
