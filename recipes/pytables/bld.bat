:: Would be nice to include blosc support, but building this with external blosc is currently broken.
::    See https://github.com/PyTables/PyTables/issues/451


:: rd /s /q c-blosc
:: git clone https://github.com/Blosc/c-blosc
:: cd c-blosc
:: git checkout v1.7.0
:: git clone https://github.com/Blosc/hdf5-blosc
:: move hdf5-blosc\src hdf5
:: rd /s /q hdf5-blosc

:: cd ..

:: %PYTHON% setup.py install --blosc=%LIBRARY_PREFIX% --hdf5=%LIBRARY_PREFIX% --bzip2=%LIBRARY_PREFIX%


:: Proceed without external blosc

%PYTHON% setup.py install --hdf5=%LIBRARY_PREFIX% --bzip2=%LIBRARY_PREFIX% ^
                          --single-version-externally-managed --record record.txt
