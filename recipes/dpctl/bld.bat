
REM A workaround for activate-dpcpp.bat issue to be addressed in 2021.4
set "LIB=%BUILD_PREFIX%\Library\lib;%BUILD_PREFIX%\compiler\lib;%LIB%"
set "INCLUDE=%BUILD_PREFIX%\include;%INCLUDE%"

"%PYTHON%" setup.py clean --all
set "INSTALL_CMD=install --sycl-compiler-prefix=%BUILD_PREFIX%\Library"

if NOT "%WHEELS_OUTPUT_FOLDER%"=="" (
    rem Install and assemble wheel package from the build bits
    "%PYTHON%" setup.py %INSTALL_CMD% bdist_wheel
    if errorlevel 1 exit 1
    copy dist\dpctl*.whl %WHEELS_OUTPUT_FOLDER%
    if errorlevel 1 exit 1
) ELSE (
    rem Only install
    "%PYTHON%" setup.py %INSTALL_CMD%
    if errorlevel 1 exit 1
)
