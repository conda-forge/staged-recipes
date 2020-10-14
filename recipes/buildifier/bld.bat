:: Turn work folder into GOPATH
set PATH=%GOPATH%\bin:%PATH%

if errorlevel 1 exit 1

:: Build
bazel build --config=release //${PKG_NAME}:${PKG_NAME}
if errorlevel 1 exit 1

:: Install Binary into %PREFIX%\bin
mkdir -p %PREFIX%\bin
if errorlevel 1 exit 1

mv bazel-bin\%PKG_NAME% %PREFIX%\bin\%PKG_NAME%
if errorlevel 1 exit 1
