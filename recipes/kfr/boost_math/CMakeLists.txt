# Stand-in for the boostorg/math checkout that KFR obtains with FetchContent:
# provides the Boost::math target from the Boost headers of the host environment.
cmake_minimum_required(VERSION 3.16)
project(boost_math_from_host LANGUAGES CXX)

find_path(BOOST_MATH_INCLUDE_DIR boost/math/special_functions/ellint_1.hpp REQUIRED)

add_library(boost_math_from_host INTERFACE)
target_include_directories(boost_math_from_host SYSTEM INTERFACE "${BOOST_MATH_INCLUDE_DIR}")
add_library(Boost::math ALIAS boost_math_from_host)
