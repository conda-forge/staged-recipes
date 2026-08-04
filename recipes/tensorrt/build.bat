@echo on

if "%PKG_NAME%"=="libnvinfer-headers" (
  bsdtar -xf tensorrt.zip --strip-components 1 "*/include/NvInfer*" "*/include/NvOnnx*" "*/doc/README.txt" "*/doc/Acknowledgements.txt"
  if errorlevel 1 exit /b 1
  del /Q tensorrt.zip
  if not exist "%LIBRARY_INC%" mkdir "%LIBRARY_INC%"
  move /Y include\NvInfer* "%LIBRARY_INC%"
  if errorlevel 1 exit /b 1
  move /Y include\NvOnnx* "%LIBRARY_INC%"
  if errorlevel 1 exit /b 1
  exit /b 0
)

if "%PKG_NAME%"=="libnvinfer" (
  bsdtar -xf tensorrt.zip --strip-components 1 "*/bin/nvinfer_[0123456789]*.dll" "*/bin/nvinfer_builder_resource_*.dll" "*/doc/README.txt" "*/doc/Acknowledgements.txt"
  if errorlevel 1 exit /b 1
  goto extracted
)

set "TRT_PATTERN="
set "TRT_BIN_PATTERN="
if "%PKG_NAME%"=="libnvinfer-devel" (
  set "TRT_PATTERN=*/lib/nvinfer_[0123456789]*.lib"
  set "TRT_BIN_PATTERN=*/bin/trtexec.exe"
)
if "%PKG_NAME%"=="libnvinfer-dispatch-devel" set "TRT_PATTERN=*/lib/nvinfer_dispatch*.lib"
if "%PKG_NAME%"=="libnvinfer-lean-devel" set "TRT_PATTERN=*/lib/nvinfer_lean*.lib"
if "%PKG_NAME%"=="libnvinfer-plugin-devel" set "TRT_PATTERN=*/lib/nvinfer_plugin*.lib"
if "%PKG_NAME%"=="libnvinfer-vc-plugin-devel" set "TRT_PATTERN=*/lib/nvinfer_vc_plugin*.lib"
if "%PKG_NAME%"=="libnvonnxparser-devel" set "TRT_PATTERN=*/lib/nvonnxparser*.lib"
if "%PKG_NAME%"=="libnvinfer-dispatch" set "TRT_PATTERN=*/bin/nvinfer_dispatch_*.dll"
if "%PKG_NAME%"=="libnvinfer-lean" set "TRT_PATTERN=*/bin/nvinfer_lean_*.dll"
if "%PKG_NAME%"=="libnvinfer-plugin" set "TRT_PATTERN=*/bin/nvinfer_plugin_*.dll"
if "%PKG_NAME%"=="libnvinfer-vc-plugin" set "TRT_PATTERN=*/bin/nvinfer_vc_plugin_*.dll"
if "%PKG_NAME%"=="libnvonnxparser" set "TRT_PATTERN=*/bin/nvonnxparser_*.dll"

if not defined TRT_PATTERN (
  echo Unknown TensorRT output: %PKG_NAME%
  exit /b 1
)

if defined TRT_BIN_PATTERN (
  bsdtar -xf tensorrt.zip --strip-components 1 "%TRT_PATTERN%" "%TRT_BIN_PATTERN%" "*/doc/README.txt" "*/doc/Acknowledgements.txt"
) else (
  bsdtar -xf tensorrt.zip --strip-components 1 "%TRT_PATTERN%" "*/doc/README.txt" "*/doc/Acknowledgements.txt"
)

:extracted
if errorlevel 1 exit /b 1

del /Q tensorrt.zip
if exist bin\*.dll (
  if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
  move /Y bin\*.dll "%LIBRARY_BIN%"
  if errorlevel 1 exit /b 1
)
if exist bin\*.exe (
  if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
  move /Y bin\*.exe "%LIBRARY_BIN%"
  if errorlevel 1 exit /b 1
)
if exist lib\*.lib (
  if not exist "%LIBRARY_LIB%" mkdir "%LIBRARY_LIB%"
  move /Y lib\*.lib "%LIBRARY_LIB%"
  if errorlevel 1 exit /b 1
)
