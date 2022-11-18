cd build

cmake --install . --prefix "%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

del "%LIBRARY_PREFIX%"\lib\libjxl*-static.lib
if errorlevel 1 exit 1

if [%PKG_NAME%] == [libjxl] (
  del "%LIBRARY_PREFIX%\bin\cjxl.exe"
  if errorlevel 1 exit 1
  del "%LIBRARY_PREFIX%\bin\djxl.exe"
  if errorlevel 1 exit 1
  del "%LIBRARY_PREFIX%\bin\cjpeg_hdr.exe"
  if errorlevel 1 exit 1
  del "%LIBRARY_PREFIX%\bin\jxlinfo.exe"
  if errorlevel 1 exit 1
)
