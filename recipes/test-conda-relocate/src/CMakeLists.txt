
set(MYPREFIX $ENV{PREFIX})
string(REGEX REPLACE "\\\\" "/" MYPREFIX_REPLACED "${MYPREFIX}")
configure_file(main.cpp.in main.cpp)
add_executable(test-conda-relocate main.cpp)
install(TARGETS test-conda-relocate DESTINATION bin)
