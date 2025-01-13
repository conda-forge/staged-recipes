mkdir %LIBRARY_INC%
copy include\*.hpp %LIBRARY_INC%

set "CXXFLAGS=%CXXFLAGS% -EHsc -MD"
make test
