:: We use the conda boost package, which includes
:: zlib support, but defining BOOST_ALL_DYN_LINK (below) makes boost try to
:: link against boost_zlib*.lib, which doesn't exist. Override this by
:: explicitly naming the boost library to link against - since there isn't
:: one, link against kernel32 instead (which pretty much everything links
:: against, so this doesn't introduce an extra dependency)
set EXTRA_CXX_FLAGS=/bigobj -DBOOST_ZLIB_BINARY=kernel32

:: tools/dev_tools is a symlink, but this doesn't always work on Windows,
:: so copy the original contents
rd /q /s tools\dev_tools
if errorlevel 1 exit 1
mkdir tools\dev_tools
if errorlevel 1 exit 1
copy modules\rmf\dependency\RMF\tools\dev_tools\* tools\dev_tools\
if errorlevel 1 exit 1
mkdir tools\dev_tools\python_tools
copy modules\rmf\dependency\RMF\tools\dev_tools\python_tools\* tools\dev_tools\python_tools\
if errorlevel 1 exit 1

:: add Python script to fix npctransport protobuf headers
copy "%RECIPE_DIR%\patch_protoc.py" modules\npctransport\patch_protoc.py
if errorlevel 1 exit 1

:: build app wrapper
copy "%RECIPE_DIR%\app_wrapper.c" .
cl app_wrapper.c shell32.lib
if errorlevel 1 exit 1

mkdir build
cd build

:: Help CMake to find CGAL
set CGAL_DIR=%PREFIX%\Library\lib\cmake\CGAL

:: Help CMake to find OpenCV
python "%RECIPE_DIR%\find_opencv_libs.py" "%PREFIX%"
if errorlevel 1 exit 1

:: Avoid running out of memory (particularly on 32-bit) by splitting up IMP.cgal
set PERCPPCOMP="-DIMP_PER_CPP_COMPILATION=cgal"

:: Don't build the scratch or cnmultifit modules
set DISABLED="scratch:cnmultifit"

cmake -DUSE_PYTHON2=off ^
      -DCMAKE_PREFIX_PATH="%PREFIX:\=/%;%PREFIX:\=/%\Library" ^
      -DCMAKE_BUILD_TYPE=Release -DIMP_DISABLED_MODULES=%DISABLED% ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_INSTALL_PYTHONDIR="%SP_DIR:\=/%" ^
      -DIMP_USE_SYSTEM_RMF=on -DIMP_USE_SYSTEM_IHM=on ^
      -DCMAKE_CXX_FLAGS="/DBOOST_ALL_DYN_LINK /EHsc /D_HDF5USEDLL_ /DH5_BUILT_AS_DYNAMIC_LIB /DPROTOBUF_USE_DLLS /DWIN32 /DGSL_DLL /DMSMPI_NO_DEPRECATE_20 %EXTRA_CXX_FLAGS%" ^
      %PERCPPCOMP% -G Ninja ..
if errorlevel 1 exit 1

:: Make sure all modules we asked for were found (this is tested for
:: in the final package, but quicker to abort here if they're missing)
python "%RECIPE_DIR%\check_disabled_modules.py" %DISABLED%
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

:: Patch IMP Python module to add paths containing Anaconda DLLs to search path
python "%RECIPE_DIR%\add_dll_search_path.py" "%SP_DIR%\IMP" "%PREFIX%\Library\bin" "%PREFIX%\Library\lib" "%SP_DIR%\IMP\__init__.py"
if errorlevel 1 exit 1

:: Add wrappers to path for each command line tool
cd bin
:: Handle Python tools (all files without an extension)
for /f %%f in ('dir /b *.') do copy "%SRC_DIR%\app_wrapper.exe" "%PREFIX%\%%f.exe"
if errorlevel 1 exit 1

:: Handle C++ tools (all files with .exe extension)
for /f %%f in ('dir /b *.exe') do copy "%SRC_DIR%\app_wrapper.exe" "%PREFIX%\%%f"
if errorlevel 1 exit 1
