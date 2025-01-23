@echo on

cmake %SRC_DIR% ^
  %CMAKE_ARGS% ^
  -B build ^
  -DBUILD_SHARED_LIBS=ON ^
  -DVSG_IMGUI_USE_SYSTEM_IMGUI=ON ^
  -DVSG_IMGUI_USE_SYSTEM_IMPLOT=ON

cmake --build build --parallel --config Release
if errorlevel 1 exit 1

cmake --install build --config Release
if errorlevel 1 exit 1
