REM set "CXXFLAGS=%CXXFLAGS:-GL=%"
REM set "CFLAGS=%CFLAGS:-GL=%"
REM set "CXXFLAGS= -MD"

set "CMAKE_GENERATOR=NMake Makefiles"
"%PYTHON%" --version
"%PYTHON%" -m pip install . --no-deps -vv
