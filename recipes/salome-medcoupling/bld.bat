git clone --depth 1 -b V9_11_0 https://git.salome-platform.org/gitpub/tools/configuration.git %SRC_DIR%/configuration

git clone --depth 1 -b V9_11_0 https://git.salome-platform.org/gitpub/tools/medcoupling.git && cd medcoupling

mkdir build && cd build
cmake -LAH -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_CXX_FLAGS="/bigobj" ^
    -DPYTHON_EXECUTABLE="%PYTHON%" ^
    -DPYTHONINTERP_ROOT_DIR="%PREFIX%" ^
    -DPYTHONLIBS_ROOT_DIR="%PREFIX%" ^
    -DPYTHON_ROOT_DIR="%PREFIX%" ^
    -DMEDCOUPLING_BUILD_DOC=OFF ^
    -DMEDCOUPLING_BUILD_TESTS=OFF ^
    -DMEDCOUPLING_PARTITIONER_SCOTCH=OFF ^
    -DMEDCOUPLING_USE_64BIT_IDS=OFF ^
    -DCONFIGURATION_ROOT_DIR=%SRC_DIR%/configuration ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

xcopy /y /s /f %LIBRARY_PREFIX%\lib\interpkernel.dll %LIBRARY_PREFIX%\bin
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medcoupling.dll %LIBRARY_PREFIX%\bin
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medcouplingremapper.dll %LIBRARY_PREFIX%\bin
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medicoco.dll %LIBRARY_PREFIX%\bin
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medloader.dll %LIBRARY_PREFIX%\bin
xcopy /y /s /f %LIBRARY_PREFIX%\lib\renumbercpp.dll %LIBRARY_PREFIX%\bin
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medpartitionercpp.dll %LIBRARY_PREFIX%\bin

xcopy /y /s /f %LIBRARY_PREFIX%\lib\interpkernel.dll %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medcoupling.dll %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medcouplingremapper.dll %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medicoco.dll %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medloader.dll %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\renumbercpp.dll %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\medpartitionercpp.dll %SP_DIR%

xcopy /y /s /f %LIBRARY_PREFIX%\lib\python%PY_VER%\site-packages\Case*.py %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\python%PY_VER%\site-packages\VTKReader.py %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\python%PY_VER%\site-packages\*medcoupling.py* %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\python%PY_VER%\site-packages\MED*.py %SP_DIR%
xcopy /y /s /f %LIBRARY_PREFIX%\lib\python%PY_VER%\site-packages\_MED*.pyd %SP_DIR%

