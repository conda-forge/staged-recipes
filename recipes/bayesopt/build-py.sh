rm python/bayesopt.cpp
cython python/bayesopt.pyx --cplus

export CXXFLAGS="${CXXFLAGS} -DBOOST_TIMER_ENABLE_DEPRECATED=1"

cd build
cmake ${CMAKE_ARGS} \
  -DBAYESOPT_PYTHON_INTERFACE=ON \
  -DBAYESOPT_BUILD_TESTS=ON \
  -DBAYESOPT_BUILD_SHARED=ON \
  -DBAYESOPT_BUILD_SOBOL=ON \
  -DNLOPT_BUILD=OFF \
  ..

make -j${CPU_COUNT}
make install
