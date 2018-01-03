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
