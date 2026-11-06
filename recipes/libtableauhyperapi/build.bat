curl -sL -o sdk.zip "%TABLEAU_URL%" || exit /b 1

for /f "skip=1 tokens=*" %%h in ('certutil -hashfile sdk.zip SHA256') do (
  if not defined ACTUAL_SHA256 set ACTUAL_SHA256=%%h
)
if /i not "%ACTUAL_SHA256%"=="%TABLEAU_SHA256%" (
  echo sha256 mismatch for %TABLEAU_URL%: expected %TABLEAU_SHA256%, got %ACTUAL_SHA256%
  exit /b 1
)

powershell -Command "Expand-Archive -Path sdk.zip -DestinationPath ." || exit /b 1

for /f "delims=" %%d in ('dir /b /ad tableauhyperapi-cxx-*') do set SDK_DIR=%%d

if not exist "%LIBRARY_INC%" mkdir "%LIBRARY_INC%" || exit /b 1
if not exist "%LIBRARY_LIB%" mkdir "%LIBRARY_LIB%" || exit /b 1
if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%" || exit /b 1
if not exist "%LIBRARY_PREFIX%\share\cmake" mkdir "%LIBRARY_PREFIX%\share\cmake" || exit /b 1

xcopy /E /I /Y "%SDK_DIR%\include\hyperapi" "%LIBRARY_INC%\hyperapi" || exit /b 1
xcopy /E /I /Y "%SDK_DIR%\share\cmake" "%LIBRARY_PREFIX%\share\cmake" || exit /b 1
xcopy /E /I /Y "%SDK_DIR%\bin\hyper" "%LIBRARY_BIN%\hyper" || exit /b 1
copy /Y "%SDK_DIR%\bin\tableauhyperapi.dll" "%LIBRARY_BIN%\" || exit /b 1
copy /Y "%SDK_DIR%\lib\tableauhyperapi.lib" "%LIBRARY_LIB%\" || exit /b 1

copy /Y "%SDK_DIR%\LICENSE" . || exit /b 1
copy /Y "%SDK_DIR%\NOTICES.txt" . || exit /b 1
copy /Y "%SDK_DIR%\HYPER_API_OSS_disclosure.txt" . || exit /b 1
