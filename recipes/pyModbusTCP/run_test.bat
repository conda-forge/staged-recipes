%PYTHON% tests/test_client_server.py
if errorlevel 1 exit 1
%PYTHON% tests/test_utils.py
if errorlevel 1 exit 1

