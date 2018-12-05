mkdir opensim_dependencies_build
cd .\opensim_dependencies_build
cmake ..\dependencies^
	-G"%CMAKE_GENERATOR"^
	-DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"^
    -DSUPERBUILD_docopt=OFF -DSUPERBUILD_simbody=OFF
cmake --build . --config Release -- /maxcpucount:%CPU_COUNT%
cd .. 

mkdir opensim_build
cd .\opensim_build
cmake ..\^
	-G"%CMAKE_GENERATOR%"^
	-DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"^
	-DOPENSIM_DEPENDENCIES_DIR="%LIBRARY_PREFIX%"^
	-DBUILD_PYTHON_WRAPPING=ON^
    -DOPENSIM_PYTHON_VERSION=3^
	-DOPENSIM_COPY_DEPENDENCIES=OFF^
    -DBUILD_API_ONLY=ON^
	-DWITH_BTK=ON
cmake --build . --target install --config Release -- /maxcpucount:%CPU_COUNT%

cp %LIBRARY_PREFIX%\simbody\bin\simbody-visualizer.exe %PREFIX%\simbody-visualizer.exe
cd %LIBRARY_PREFIX%\sdk\python
python setup.py install
