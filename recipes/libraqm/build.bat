@echo on

meson build
if %ERRORLEVEL% neq 0 exit 1

ninja -C build
if %ERRORLEVEL% neq 0 exit 1

ninja -C build install
if %ERRORLEVEL% neq 0 exit 1
