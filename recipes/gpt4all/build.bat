@echo on

@REM For ctest after build
set PATH=%SRC_DIR%\build;%SRC_DIR%\build\bin;%SRC_DIR%\build\Release;%SRC_DIR%\build\release;%PATH%
if errorlevel 1 exit 1

git submodule update --init --recursive

pushd gpt4all-backend
if errorlevel 1 exit 1

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DLLMODEL_KOMPUTE=OFF ^
    -DLLMODEL_VULKAN=ON ^
    -DLLMODEL_CUDA=OFF ^
    -DLLMODEL_ROCM=OFF

if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest --test-dir build
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1

pushd gpt4all-bindings\python
if errorlevel 1 exit 1

pip install .
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1
