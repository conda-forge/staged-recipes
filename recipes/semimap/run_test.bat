@REM Test the installation of the library
if not exist %LIBRARY_PREFIX%\include\semimap\semimap.h (exit 1)
if not exist %LIBRARY_PREFIX%\test\test.cpp (exit 1)  # [win]

@REM Compile and run the test suite
%CXX% %CXXFLAGS% -std=c++17 -Wall -I %PREFIX%\include\semimap %PREFIX%\test\test.cpp -o test_suite

.\test_suite
del .\test_suite
