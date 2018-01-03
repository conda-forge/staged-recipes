for /F "usebackq tokens=3*" %%A in (`REG QUERY "HKEY_LOCAL_MACHINE\Software\Microsoft\DevDiv\VC\Servicing\9.0\IDE" /v UpdateVersion`) do (
    set SP=%%A
)

if not "%SP%" == "%PKG_VERSION%" (
    echo "Version detected from registry: %SP%"
    echo    "does not match version of package being built (%PKG_VERSION%)"
    echo "Do you have current updates for VS 2008 installed?"
    exit 1
)

for %%F in ("." "bin") do (
    cmake -G "%CMAKE_GENERATOR%" ^
          -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
          -DCMAKE_INSTALL_DEBUG_LIBRARIES:BOOL="OFF" ^
          -DCMAKE_INSTALL_DEBUG_LIBRARIES_ONLY:BOOL="OFF" ^
          -DCMAKE_INSTALL_OPENMP_LIBRARIES:BOOL="ON" ^
          -DCMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION:STRING=%%F ^
          "%RECIPE_DIR%"
    if errorlevel 1 exit 1

    cmake --build "%SRC_DIR%" ^
          --target INSTALL ^
          --config Release
    if errorlevel 1 exit 1
)
