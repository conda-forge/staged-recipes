powershell -Command "(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/d/d/9/dd9a82d0-52ef-40db-8dab-795376989c03/vcredist_x86.exe', 'vcredist_x86.exe')"
if errorlevel 1 exit 1
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/2/d/6/2d61c766-107b-409d-8fba-c39e61ca08e8/vcredist_x64.exe', 'vcredist_x64.exe')"
if errorlevel 1 exit 1

vcredist_x86.exe /qb!
if errorlevel 1 exit 1
vcredist_x64.exe /qb!
if errorlevel 1 exit 1

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
