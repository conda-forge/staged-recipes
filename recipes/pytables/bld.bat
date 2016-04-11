REM Would be nice to include blosc support, but building this with external blosc is currently broken.
REM    See https://github.com/PyTables/PyTables/issues/451


REM rd /s /q c-blosc
REM git clone https://github.com/Blosc/c-blosc
REM cd c-blosc
REM git checkout v1.7.0
REM git clone https://github.com/Blosc/hdf5-blosc
REM move hdf5-blosc\src hdf5
REM rd /s /q hdf5-blosc

REM cd ..

REM %PYTHON% setup.py install --blosc=%LIBRARY_PREFIX% --hdf5=%LIBRARY_PREFIX% --bzip2=%LIBRARY_PREFIX%


REM Proceed without external blosc

%PYTHON% setup.py install --hdf5=%LIBRARY_PREFIX% --bzip2=%LIBRARY_PREFIX%

if %PY3K%==1 (
    rd /s /q %SP_DIR%\numpy
    rd /s /q %SP_DIR%\__pycache__
    rd /s /q %SP_DIR%\Cython
)
