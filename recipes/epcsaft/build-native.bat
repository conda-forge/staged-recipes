@echo on
setlocal
call run_autotools_clang_conda_build.bat build-ipopt.sh
if errorlevel 1 exit /b 1
endlocal
call "%RECIPE_DIR%\build-env.bat"
set "TOOLS_PYTHON=%BUILD_PREFIX%\python.exe"
set "NATIVE_BUILD=%BUILD_PREFIX%\epcsaft-native-build"
set "STAGE=engine\conda-native"
xcopy /e /i /y /q engine\build\subprojects\packagefiles\cppad engine\build\subprojects\CppAD-20250000.3
if errorlevel 1 exit /b 1
"%TOOLS_PYTHON%" -m mesonbuild.mesonmain setup "%NATIVE_BUILD%" engine --wrap-mode=nodownload -Depcsaft_build=native
if errorlevel 1 exit /b 1
"%TOOLS_PYTHON%" "%RECIPE_DIR%\build-jobs.py" native-ninja > jobs.txt
if errorlevel 1 exit /b 1
set JOBS=
set /p JOBS=<jobs.txt
if not defined JOBS exit /b 1
"%TOOLS_PYTHON%" -m mesonbuild.mesonmain compile -C "%NATIVE_BUILD%" -j%JOBS% -v
if errorlevel 1 exit /b 1
mkdir "%STAGE%\cppad"
for %%F in (epcsaft_native.dll epcsaft_native.lib epcsaft_asl.dll epcsaft_asl.lib) do (
    copy "%NATIVE_BUILD%\%%F" "%STAGE%\"
    if errorlevel 1 exit /b 1
)
copy "%NATIVE_BUILD%\build\subprojects\CppAD-20250000.3\cppad\configure.hpp" "%STAGE%\cppad\"
if errorlevel 1 exit /b 1
