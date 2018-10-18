echo on
set BLPAPI_ROOT=%SRC_DIR%\blpapi-cpp
cd %SRC_DIR%\blpapi-py
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt