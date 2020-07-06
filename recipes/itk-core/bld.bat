%PYTHON% setup.py install --build-type Release -G Ninja -- \
  -DITKPythonPackage_ITK_BINARY_REUSE:BOOL=OFF \
  -DITKPythonPackage_WHEEL_NAME:STRING="itk" \
  -DITK_WRAP_unsigned_short:BOOL=ON \
  -DPYTHON_EXECUTABLE:FILEPATH=%PYTHON% \
  -DITK_WRAP_DOC:BOOL=ON

if errorlevel 1 exit 1
