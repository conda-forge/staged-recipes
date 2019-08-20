:: This wrapper script is necessary to make the "f2py" command on windows work

@SET "PYTHON_EXE=%~dp0\..\python.exe"
call "%PYTHON_EXE%" "%~dp0\f2py.py" %*
