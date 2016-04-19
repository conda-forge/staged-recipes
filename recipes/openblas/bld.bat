
:: Set $HOME to the current dir so msys runs here
set HOME=%cd%

:: Configure, build, test, and install using `nmake`.
bash -lc "make"
if errorlevel 1 exit 1
bash -lc "make DYNAMIC_ARCH=1 BINARY=$ARCH NO_LAPACK=0 NO_AFFINITY=1 USE_THREAD=1 PREFIX=$LIBRARY_PREFIX install"
if errorlevel 1 exit 1
