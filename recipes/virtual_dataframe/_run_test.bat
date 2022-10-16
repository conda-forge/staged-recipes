timeout 5
%PYTHON% -c "import virtual_dataframe ; print(virtual_dataframe.VDF_MODE)"
if errorlevel 1 exit 1
