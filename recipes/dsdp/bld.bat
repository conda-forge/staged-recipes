

copy %RECIPE_DIR%\Makefile_win %SRC_DIR%
copy %RECIPE_DIR%\dsdp.def %SRC_DIR%
nmake /f Makefile_win

copy dsdp.lib %LIBRARY_PREFIX%\lib
copy dsdp.dll %LIBRARY_PREFIX%\bin
copy include\*.h %LIBRARY_PREFIX%\include

rem copy dsdp5.exe %LIBRARY_PREFIX%\bin
