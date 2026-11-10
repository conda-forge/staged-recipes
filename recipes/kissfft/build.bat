@echo on

:: One shared library per datatype (kissfft-float.dll, kissfft-double.dll).
:: CMAKE_INSTALL_*DIR must be passed explicitly: upstream only includes
:: GNUInstallDirs on Linux, so they would otherwise be empty on Windows.
for %%D in (float double) do (
  cmake -G Ninja -B _build_%%D -S . %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_INSTALL_INCLUDEDIR=include ^
    -DCMAKE_INSTALL_BINDIR=bin ^
    -DKISSFFT_DATATYPE=%%D ^
    -DKISSFFT_STATIC=OFF ^
    -DKISSFFT_OPENMP=OFF ^
    -DKISSFFT_PKGCONFIG=ON ^
    -DKISSFFT_TOOLS=OFF ^
    -DKISSFFT_TEST=OFF
  if errorlevel 1 exit 1
  cmake --build _build_%%D --parallel %CPU_COUNT%
  if errorlevel 1 exit 1
  cmake --install _build_%%D
  if errorlevel 1 exit 1
)
