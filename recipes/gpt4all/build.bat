@echo on

pushd gpt4all-backend
if errorlevel 1 exit 1

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DLLMODEL_KOMPUTE=ON ^
    -DLLMODEL_VULKAN=ON ^
    -DLLMODEL_CUDA=OFF ^
    -DLLMODEL_ROCM=OFF

if errorlevel 1 exit 1

:: Build the vulkan-shaders-gen target first (if present)
cmake --build build --target vulkan-shaders-gen --parallel %CPU_COUNT%
if errorlevel 1 echo "vulkan-shaders-gen build failed or not present, continuing..."

:: Locate the built vulkan-shaders-gen executable in common locations
set "GEN_EXE="
if exist "%CD%\build\vulkan-shaders-gen.exe" set "GEN_EXE=%CD%\build\vulkan-shaders-gen.exe"
if exist "%CD%\build\bin\vulkan-shaders-gen.exe" set "GEN_EXE=%CD%\build\bin\vulkan-shaders-gen.exe"
if exist "%CD%\build\Debug\vulkan-shaders-gen.exe" set "GEN_EXE=%CD%\build\Debug\vulkan-shaders-gen.exe"
if exist "%CD%\build\Release\vulkan-shaders-gen.exe" set "GEN_EXE=%CD%\build\Release\vulkan-shaders-gen.exe"
if exist "%CD%\build\bin\Debug\vulkan-shaders-gen.exe" set "GEN_EXE=%CD%\build\bin\Debug\vulkan-shaders-gen.exe"
if exist "%CD%\build\bin\Release\vulkan-shaders-gen.exe" set "GEN_EXE=%CD%\build\bin\Release\vulkan-shaders-gen.exe"

if defined GEN_EXE (
    echo Running vulkan-shaders-gen: %GEN_EXE%
    "%GEN_EXE%" --glslc "%BUILD_PREFIX%\bin\glslc" --input-dir "%SRC_DIR%\gpt4all-backend\deps\llama.cpp-mainline\ggml\src\vulkan-shaders" --output-dir "%CD%\build\vulkan-shaders.spv" --target-hpp "%CD%\build\ggml-vulkan-shaders.hpp" --target-cpp "%CD%\build\ggml-vulkan-shaders.cpp" --no-clean
    if errorlevel 1 echo "vulkan-shaders-gen execution failed (but continuing)"
) else (
    echo "vulkan-shaders-gen not found; continuing build (may fail if Vulkan is enabled)"
)

:: Build the rest
cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1

pushd gpt4all-bindings\python
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1
