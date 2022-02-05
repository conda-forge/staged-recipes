mkdir opensim_dependencies_build
cd .\opensim_dependencies_build
cmake ..\dependencies^
	-G"Visual Studio 16 2019"^
	-DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"^
	-DSUPERBUILD_ezc3d=ON
cmake --build . --config Release -- /maxcpucount:8
cd .. 

mkdir opensim_build
cd .\opensim_build
cmake ..\^
	-G"Visual Studio 16 2019"^
	-DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"^
	-DOPENSIM_DEPENDENCIES_DIR="%LIBRARY_PREFIX%"^
	-DBUILD_PYTHON_WRAPPING=ON^
	-DOPENSIM_C3D_PARSER=ezc3d^
	-DOPENSIM_PYTHON_STANDALONE=ON^
	-DBUILD_TESTING=OFF^
	-DOPENSIM_PYTHON_CONDA=ON
cmake --build . --target install --config Release -- /maxcpucount:8

copy %LIBRARY_PREFIX%\simbody\bin\simbody-visualizer.exe %PREFIX%\simbody-visualizer.exe
cd %LIBRARY_PREFIX%\sdk\python
python setup.py install
