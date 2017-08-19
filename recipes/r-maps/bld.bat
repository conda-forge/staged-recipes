:: Not sure why this leaks to the build flags and break the build.
:: See https://github.com/conda-forge/r-maps-feedstock/issues/1
set TARGET_ARCH=

"%R%" CMD INSTALL --build .
if errorlevel 1 exit 1
