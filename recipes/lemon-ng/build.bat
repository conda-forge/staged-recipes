:: a static library on Windows, since LEMON declares no symbol for a DLL
cmake -S . -B build -G Ninja %CMAKE_ARGS% -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DBUILD_SHARED_LIBS=OFF -DLEMON_VERSION=%PKG_VERSION% ^
  -DLEMON_BUILD_TESTS=NO -DLEMON_BUILD_DEMOS=NO -DLEMON_BUILD_TOOLS=NO ^
  -DLEMON_BUILD_DOC=NO -DLEMON_ENABLE_GLPK=NO -DLEMON_ENABLE_ILOG=NO ^
  -DLEMON_ENABLE_COIN=NO -DLEMON_ENABLE_SOPLEX=NO
if errorlevel 1 exit 1
cmake --build build
if errorlevel 1 exit 1
cmake --install build
if errorlevel 1 exit 1
