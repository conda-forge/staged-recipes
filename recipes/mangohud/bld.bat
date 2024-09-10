@echo on
setlocal EnableDelayedExpansion

set PYTHON=%BUILD_PREFIX%\python.exe
echo %PYTHON%
where python
python --version
meson setup ^
    build ^
    %MESON_ARGS% ^
    -Duse_system_spdlog=enabled ^
    -Dinclude_doc=false ^
    -Dwith_nvml=disabled ^
    -Dwith_xnvctrl=disabled ^
    -Dmangoplot=disabled ^
    -Ddynamic_string_tokens=false
if errorlevel 1 exit 1

ninja -j%CPU_COUNT% -C build
if errorlevel 1 exit 1

ninja -C build install
if errorlevel 1 exit 1
