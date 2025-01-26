@echo on

:: Remove existing imgui and implot headers to use the external ones installed by their Conda packages
del /q include\vsgImGui\imgui.h
del /q include\vsgImGui\implot.h
if errorlevel 1 exit 1

cmake %SRC_DIR% ^
  %CMAKE_ARGS% ^
  -B build ^
  -DBUILD_SHARED_LIBS=ON
if errorlevel 1 exit 1

cmake --build build --parallel --config Release
if errorlevel 1 exit 1

cmake --install build --config Release
if errorlevel 1 exit 1
