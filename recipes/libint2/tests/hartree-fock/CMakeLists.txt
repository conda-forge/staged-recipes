cmake_minimum_required(VERSION 3.16)
project(hf++)

if (MSVC)
      set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH} $ENV{LIBRARY_PREFIX}")
else()
      set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH} $ENV{PREFIX}")
endif()

find_package(Libint2 2.7.2 REQUIRED COMPONENTS eri_c4_d0_l2 CXX_ho)
get_target_property(_l2_ver Libint2::int2 Libint2_VERSION)
get_target_property(_l2_mam Libint2::int2 Libint2_MAX_AM_ERI)
get_target_property(_l2_con Libint2::int2 Libint2_CONFIGURATION)
message("A ${LIBINT_VERSION} B ${Libint2_VERSION} C ${LIBINT2_VERSION}")
message("tgt Libint2_VERSION       ${_l2_ver}")
message("tgt Libint2_MAX_AM_ERI    ${_l2_mam}")
message("tgt Libint2_CONFIGURATION ${_l2_con}")


find_package(Threads)  # clang does not autolink threads even though we are using std::thread

add_executable(hf++ "hartree-fock++.cc")
target_link_libraries(hf++ Libint2::cxx Threads::Threads)

# cmake -S. -Bbuild -D LIBINT2_BUILD_SHARED_AND_STATIC_LIBS=ON -D Eigen3_DIR="/psi/toolchainconda/envs/singleeigen/share/eigen3/cmake" -D Boost_DIR="/psi/toolchainconda/envs/singleboost/lib/cmake/Boost-1.73.0"
# cmake --build build -j12 #--target hf++
# ./build/hf++ ../src/lib/libint/tests/hartree-fock/h2o_rotated.xyz | python ../src/lib/libint/tests/hartree-fock/hartree-fock++-validate.py build/_deps/myl2-src/features


