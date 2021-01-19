:: remove -GL from CXXFLAGS
set "CXXFLAGS=-MD"

:: Build ParaView first
mkdir paraview-build && cd paraview-build
cmake -LAH -G"Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR:PATH="Library/lib" ^
    -DCMAKE_INSTALL_BINDIR:PATH="Library/bin" ^
    -DCMAKE_INSTALL_INCLUDEDIR:PATH="Library/include" ^
    -DCMAKE_INSTALL_DATAROOTDIR:PATH="Library/share" ^
    -DPython3_FIND_STRATEGY:STRING=LOCATION ^
    -DPython3_ROOT_DIR:PATH="%PREFIX%" ^
    -DPARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX:PATH="Lib/site-packages" ^
    -DPARAVIEW_ENABLE_CATALYST:BOOL=OFF  ^
    -DPARAVIEW_ENABLE_PYTHON:BOOL=ON  ^
    -DPARAVIEW_ENABLE_WEB:BOOL=OFF  ^
    -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION:BOOL=OFF  ^
    -DPARAVIEW_USE_QTHELP:BOOL=OFF  ^
    -DPARAVIEW_PLUGINS_DEFAULT:BOOL=OFF  ^
    -DPARAVIEW_USE_VTKM:BOOL=OFF  ^
    -DPARAVIEW_CUSTOM_LIBRARY_SUFFIX:STRING=tpv5.7 ^
    -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB  ^
    -DVTK_PYTHON_VERSION:STRING=3  ^
    -DVTK_PYTHON_FULL_THREADSAFE:BOOL=ON  ^
    -DVTK_NO_PYTHON_THREADS:BOOL=OFF  ^
    ..\paraview
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

:: Now Tomviz
cd .. && mkdir tomviz-build && cd tomviz-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX:PATH="%PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_LIBDIR:PATH="Library/lib" ^
  -DCMAKE_INSTALL_BINDI:PATH="Library/bin" ^
  -DCMAKE_INSTALL_INCLUDEDIR:PATH="Library/include" ^
  -DCMAKE_INSTALL_DATAROOTDIR:PATH="Library/share" ^
  -DParaView_DIR:PATH="%SRC_DIR%/paraview-build" ^
  -DBUILD_TESTING:BOOL=OFF ^
  -DPython3_FIND_STRATEGY:STRING=LOCATION ^
  -DPython3_ROOT_DIR:PATH="%PREFIX%" ^
  ..\tomviz
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1
