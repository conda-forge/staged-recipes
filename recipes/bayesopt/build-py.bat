del python/bayesopt.cpp
cython python/bayesopt.pyx --cplus

set "CXXFLAGS=%CXXFLAGS% -DBOOST_TIMER_ENABLE_DEPRECATED=1"

cd build
cmake %CMAKE_ARGS% ^
  -G Ninja ^
  -DBAYESOPT_PYTHON_INTERFACE=ON ^
  -DBAYESOPT_BUILD_TESTS=ON ^
  -DBAYESOPT_BUILD_SHARED=ON ^
  -DBAYESOPT_BUILD_SOBOL=ON ^
  -DNLOPT_BUILD=OFF ^
  ..

ninja -j%CPU_COUNT%
ninja install
