REM set "CXXFLAGS=%CXXFLAGS:-GL=%"
REM set "CFLAGS=%CFLAGS:-GL=%"
REM set "CXXFLAGS= -MD"

set "CMAKE_GENERATOR=Ninja"
"%PYTHON%" --version
"%PYTHON%" -m pip install . --no-deps -vv
