@echo on

set "LLVM_DIR=%LIBRARY_PREFIX%\lib\cmake\llvm"
set "CMAKE_GENERATOR=Ninja"
set "CMAKE_GENERATOR_INSTANCE="
set "CMAKE_GENERATOR_PLATFORM="
set "CMAKE_GENERATOR_TOOLSET="
set "CMAKE_BUILD_PARALLEL_LEVEL=%CPU_COUNT%"
set "SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%"

rem Quadrants invokes Clang separately to emit embedded LLVM runtime bitcode.
set "CLANG_EXECUTABLE=%BUILD_PREFIX%\Library\bin\clang++.exe"
if not exist "%CLANG_EXECUTABLE%" set "CLANG_EXECUTABLE=%BUILD_PREFIX%\Library\bin\clang.exe"
set "CLANG_EXECUTABLE=%CLANG_EXECUTABLE:\=/%"

rem Upstream forcibly disables AMDGPU on Windows; CUDA and Vulkan are supported.
set "CMAKE_ARGS=%CMAKE_ARGS% -DQD_WITH_CUDA=ON -DQD_WITH_AMDGPU=OFF -DQD_WITH_VULKAN=ON -DQD_WITH_METAL=OFF -DQD_USE_SYSTEM_DEPS=ON -DQD_BUILD_TESTS=OFF -DSPIRV_WERROR=OFF -DCLANG_EXECUTABLE=%CLANG_EXECUTABLE%"

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
