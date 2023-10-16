set FFLAGS=-static-libgfortran
set LDFLAGS=-static
set "CMAKE_GENERATOR=MinGW Makefiles"
"%PYTHON%" -m pip install . -vv
