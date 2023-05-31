@echo on


set "CXXFLAGS=%CXXFLAGS% \D_LIBCPP_DISABLE_AVAILABILITY"

%PYTHON% -m pip install . --no-deps -vv
if %ERRORLEVEL% neq 0 exit 1