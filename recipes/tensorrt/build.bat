@echo on

if "%PKG_NAME%"=="tensorrt-libs" (
  tar -xf tensorrt.zip --strip-components 1 "*/doc/README.txt" "*/doc/Acknowledgements.txt"
  if errorlevel 1 exit /b 1
  del /Q tensorrt.zip
  exit /b 0
)

if "%PKG_NAME%"=="libnvinfer" (
  tar -xf tensorrt.zip --strip-components 1 "*/bin/nvinfer_[0123456789]*.dll" "*/bin/nvinfer_builder_resource_*.dll" "*/doc/README.txt" "*/doc/Acknowledgements.txt"
  if errorlevel 1 exit /b 1
  goto extracted
)

set "TRT_PATTERN="
if "%PKG_NAME%"=="libnvinfer-dispatch" set "TRT_PATTERN=*/bin/nvinfer_dispatch_*.dll"
if "%PKG_NAME%"=="libnvinfer-lean" set "TRT_PATTERN=*/bin/nvinfer_lean_*.dll"
if "%PKG_NAME%"=="libnvinfer-plugin" set "TRT_PATTERN=*/bin/nvinfer_plugin_*.dll"
if "%PKG_NAME%"=="libnvinfer-vc-plugin" set "TRT_PATTERN=*/bin/nvinfer_vc_plugin_*.dll"
if "%PKG_NAME%"=="libnvonnxparser" set "TRT_PATTERN=*/bin/nvonnxparser_*.dll"

if not defined TRT_PATTERN (
  echo Unknown TensorRT output: %PKG_NAME%
  exit /b 1
)

tar -xf tensorrt.zip --strip-components 1 "%TRT_PATTERN%" "*/doc/README.txt" "*/doc/Acknowledgements.txt"

:extracted
if errorlevel 1 exit /b 1

del /Q tensorrt.zip
if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
move /Y bin\*.dll "%LIBRARY_BIN%"
if errorlevel 1 exit /b 1
