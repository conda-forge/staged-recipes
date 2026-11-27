cmake_minimum_required(VERSION 3.20)
project(smf_consumer_test C)

enable_testing()
find_package(smf CONFIG REQUIRED)

add_executable(test_smf test_smf.c)
target_link_libraries(test_smf PRIVATE smf::smf_c)
if(UNIX)
    target_link_libraries(test_smf PRIVATE m)
endif()
add_test(NAME test_smf COMMAND test_smf)
