:: test the command line interface
lp_solve -mps plan.mps

:: FIXME: the following section doesn't work because cl.exe isn't available

:::: compile a small program against the library
::cl /DWIN32 /I %LIBRARY_INC% demo.c /link /LIBPATH:%LIBRARY_LIB% lpsolve55.lib
::if errorlevel 1 exit 1
:::: test the compiled program
::demo.exe
::if errorlevel 1 exit 1
