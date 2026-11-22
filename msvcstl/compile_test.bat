@echo on
setlocal enableextensions
setlocal enabledelayedexpansion

pushd test_sources || goto :error
for /f "usebackq" %%i in (`dir /b ^| findstr /i "^.*\.cpp$"`) do (
    cl.exe /O2 /Zi /DEBUG /MD ^
    	/I "%LIBRARY_INC%\c++\v1" ^
	/I "%LIBRARY_INC%" ^
	%%i /Fe:test_cl.exe ^
	/link /NODEFAULTLIB ^
	/LIBPATH:"%LIBRARY_LIB%" ^
	msvcprt.lib vcruntime.lib ucrt.lib msvcrt.lib kernel32.lib || goto :error
    test_cl.exe || goto :error
)
popd || goto :error

pushd test_sources\cpp11 || goto :error
for /f "usebackq" %%i in (`dir /b ^| findstr /i "^.*\.cpp$"`) do (
    cl.exe /O2 /Zi /DEBUG /MD ^
    	/I "%LIBRARY_INC%\c++\v1" ^
	/I "%LIBRARY_INC%" ^
	%%i /Fe:test_cl.exe ^
	/link /NODEFAULTLIB ^
	/LIBPATH:"%LIBRARY_LIB%" ^
	msvcprt.lib vcruntime.lib ucrt.lib msvcrt.lib kernel32.lib || goto :error
    test_cl.exe || goto :error
)
popd || goto :error

pushd test_sources\cpp14 || goto :error
for /f "usebackq" %%i in (`dir /b ^| findstr /i "^.*\.cpp$"`) do (
    cl.exe /O2 /Zi /DEBUG /MD /std:c++14 ^
    	/I "%LIBRARY_INC%\c++\v1" ^
	/I "%LIBRARY_INC%" ^
	%%i /Fe:test_cl.exe ^
	/link /NODEFAULTLIB ^
	/LIBPATH:"%LIBRARY_LIB%" ^
	msvcprt.lib vcruntime.lib ucrt.lib msvcrt.lib kernel32.lib || goto :error
    test_cl.exe || goto :error
)
popd || goto :error

goto :eof

:error
echo Failed with error#%errorlevel%.
exit 1
