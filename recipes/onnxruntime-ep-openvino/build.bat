@echo on

mkdir ort-root\include\onnxruntime
if errorlevel 1 exit 1
copy "%LIBRARY_INC%\onnxruntime\core\session\*.h" ort-root\include\onnxruntime\
if errorlevel 1 exit 1
copy "%LIBRARY_INC%\onnxruntime\core\session\*.inc" ort-root\include\onnxruntime\
if errorlevel 1 exit 1
set "ONNXRUNTIME_ROOT_DIR=%SRC_DIR%\ort-root"
set "INTEL_OPENVINO_DIR=%LIBRARY_PREFIX%"

cmake -G Ninja -B build %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DOVEP_PLUGIN_BUILD_TESTS=OFF ^
    -DOVEP_PLUGIN_BUILD_TOOLS=OFF ^
    -DOVEP_PLUGIN_BUNDLE_RUNTIME=OFF ^
    -DOVEP_PLUGIN_PRODUCTION_BUILD=ON ^
    -DOVEP_PLUGIN_USE_MSVC_STATIC_RUNTIME=OFF ^
    -DGIT_COMMIT_ID=v%PKG_VERSION% ^
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON
if errorlevel 1 exit 1
cmake --build build --target onnxruntime_providers_openvino_plugin --parallel %CPU_COUNT%
if errorlevel 1 exit 1

copy build\plugin\onnxruntime_providers_openvino_plugin.dll "%LIBRARY_BIN%\"
if errorlevel 1 exit 1
