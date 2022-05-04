REM set "CXXFLAGS=%CXXFLAGS:-GL=%"
REM set "CFLAGS=%CFLAGS:-GL=%"
REM set "CXXFLAGS= -MD"

set "CMAKE_GENERATOR=Visual Studio 15 2017"
"%PYTHON%" --version
"%PYTHON%" -m pip install . --no-deps -vv
