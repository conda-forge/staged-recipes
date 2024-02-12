export CXXFLAGS="${CXXFLAGS} -DBOOST_TIMER_ENABLE_DEPRECATED=1"

mkdir build
cd build
cmake ${CMAKE_ARGS} \
  -DBAYESOPT_PYTHON_INTERFACE=OFF \
  -DBAYESOPT_BUILD_TESTS=ON \
  -DBAYESOPT_BUILD_SHARED=ON \
  -DBAYESOPT_BUILD_SOBOL=ON \
  -DNLOPT_BUILD=OFF \
  ..

make -j${CPU_COUNT}
make install

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" || "$CROSSCOMPILING_EMUALTOR" != "" ]]; then
  bin/parsetest
  bin/gridtest
  bin/randtest
  bin/test_fileparser
  bin/test_initial_samples
  bin/test_save
  bin/test_restore
fi
