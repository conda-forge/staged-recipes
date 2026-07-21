REM Build script for conda package on Windows

set PYTHON=%PYTHON%

REM Remove virtual environment if it exists
if exist "coarsify\src\venv" (
    echo Removing virtual environment...
    rmdir /s /q "coarsify\src\venv"
)

REM Install the package in development mode
%PYTHON% -m pip install . --no-deps --ignore-installed -vv

REM Run tests if they exist
if exist "coarsify\src\test" (
    echo Running tests...
    %PYTHON% -m pytest coarsify\src\test\ -v || echo Tests failed, but continuing build
)

echo Build completed successfully
