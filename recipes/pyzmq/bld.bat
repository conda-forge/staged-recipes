set DISTUTILS_USE_SDK=1


:: For now, we build pyzmq with the bundled zeromq for py<35. There were a number of reasons for
:: this, including lib\libzmq.dll not being available, as well as
:: src\stdint.hpp not being available.
:: https://github.com/conda-forge/staged-recipes/pull/292 has some more detail.

SET ZMQ=%LIBRARY_PREFIX%
IF "%CONDA_PY% == "27" SET ZMQ=bundled
IF "%CONDA_PY% == "34" SET ZMQ=bundled

"%PYTHON%" setup.py configure --zmq=%ZMQ%
if errorlevel 1 exit 1

"%PYTHON%" setup.py install
if errorlevel 1 exit 1
