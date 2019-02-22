cmake ^
      -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DWITH_INCHI=ON ^
      -DPython_ADDITIONAL_VERSIONS=${PY_VER} ^
      -DPYTHON_EXECUTABLE=%PYTHON% ^
      -DPYTHON_INCLUDE_DIR=%PREFIX%\include ^
      -DPYTHON_LIBRARY="%PREFIX%\libs\python%CONDA_PY%.lib" ^
      -DPYTHON_BINDINGS=ON ^
      -DRUN_SWIG=ON ^
      -DCMAKE_BUILD_TYPE=Release ^
      .

cmake --build . --target install --config Release

echo d|xcopy %LIBRARY_PREFIX%\bin\data %PREFIX%\share\openbabel /e /c
rmdir /s /q %LIBRARY_PREFIX%\bin\data

xcopy %LIBRARY_PREFIX%\Lib\site-packages %PREFIX%\Lib /e /c
rmdir /s /q %LIBRARY_PREFIX%\Lib\site-packages
