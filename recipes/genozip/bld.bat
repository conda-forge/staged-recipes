rem cl.exe /D_LARGEFILE64_SOURCE=1 /O2 -Tp  -Tc  

make all

rem copy genozip.exe %PREFIX%\bin\genozip.exe
copy genozip.exe genounzip.exe
copy genozip.exe genocat.exe
copy genozip.exe genols.exe

exit /b 0

rem copy %RECIPE_DIR%\LICENSE.non-commerical.txt %PREFIX%
rem copy %RECIPE_DIR%\LICENSE.commerical.txt %PREFIX%

 
