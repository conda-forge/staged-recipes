@echo off

powershell -Command "& { %RECIPE_DIR%\helpers\build.ps1 }"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

:: Delete extra files
del %PREFIX%\\Library\\lib\\dydx_v4_proto.lib
del %PREFIX%\\Library\\lib\\pkgconfig\\dydx_v4_proto.pc
del %PREFIX%\\Library\\lib\\cmake\\dydx_v4_proto/dydx_v4_proto-config.cmake

del %PREFIX%\\Library\\bin\\dydx_v4_proto-*.dll
