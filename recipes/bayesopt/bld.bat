del python/bayesopt.cpp
cython python/bayesopt.pyx --cplus

set "CXXFLAGS=%CXXFLAGS% -DBOOST_TIMER_ENABLE_DEPRECATED=1"

mkdir build
cd build
cmake %CMAKE_ARGS% ^
  -DBAYESOPT_PYTHON_INTERFACE=ON ^
  -DBAYESOPT_BUILD_TESTS=ON ^
  -DBAYESOPT_BUILD_SHARED=ON ^
  -DBAYESOPT_BUILD_SOBOL=ON ^
  -DNLOPT_BUILD=OFF ^
  ..

ninja -j%CPU_COUNT%
ninja install

bin/parsetest.exe
bin/gridtest.exe
bin/randtest.exe
bin/test_fileparser.exe
bin/test_initial_samples.exe
bin/test_save.exe
bin/test_restore.exe
