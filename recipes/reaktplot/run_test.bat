@REM Execute the Python test application using reaktplot
python test/example.py

@REM Build and execute the C++ test application using reaktplot
cd test/app
mkdir build
cd build
cmake -GNinja ..                         ^
    -DCMAKE_BUILD_TYPE=Release           ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%
ninja
@REM app.exe

@REM Executing app.exe in Windows is causing the following error (which will be figured out in the future time permitting!)
@REM
@REM [1/2] Building CXX object CMakeFiles\app.dir\main.cpp.obj
@REM [2/2] Linking CXX executable app.exe
@REM Python path configuration:
@REM   PYTHONHOME = (not set)
@REM   PYTHONPATH = (not set)
@REM   program name = 'python'
@REM   isolated = 0
@REM   environment = 1
@REM   user site = 0
@REM   import site = 1
@REM   sys._base_executable = 'C:\\bld\\reaktplot_1663251751850\\test_tmp\\test\\app\\build\\app.exe'
@REM   sys.base_prefix = 'C:\\bld\\reaktplot_1663251751850\\_test_env'
@REM   sys.base_exec_prefix = 'C:\\bld\\reaktplot_1663251751850\\_test_env'
@REM   sys.executable = 'C:\\bld\\reaktplot_1663251751850\\test_tmp\\test\\app\\build\\app.exe'
@REM   sys.prefix = 'C:\\bld\\reaktplot_1663251751850\\_test_env'
@REM   sys.exec_prefix = 'C:\\bld\\reaktplot_1663251751850\\_test_env'
@REM   sys.path = [
@REM     'C:\\bld\\reaktplot_1663251751850\\_test_env\\python38.zip',
@REM     '.\\DLLs',
@REM     '.\\lib',
@REM     'C:\\bld\\reaktplot_1663251751850\\test_tmp\\test\\app\\build',
@REM   ]
@REM Fatal Python error: init_fs_encoding: failed to get the Python codec of the filesystem encoding
@REM Python runtime state: core initialized
@REM ModuleNotFoundError: No module named 'encodings'
@REM
@REM Maybe installing package `encodings` could fix this?! (Allan Leal, 15.09.2022)
