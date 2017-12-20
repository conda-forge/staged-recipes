:: build static and shared libraries
cd lpsolve55
call cvc8msvcrt
cd ..

:: build executable
cd lp_solve
call cvc8
cd ..

:: install binaries and headers
xcopy lpsolve55\bin\win%ARCH%\*.dll %LIBRARY_BIN%\
xcopy lpsolve55\bin\win%ARCH%\*.lib %LIBRARY_LIB%\
xcopy *.h %LIBRARY_INC%\
xcopy lp_solve\bin\win%ARCH%\lp_solve.exe %LIBRARY_BIN%\
