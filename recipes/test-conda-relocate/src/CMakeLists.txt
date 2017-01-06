
set(MYPREFIX $ENV{PREFIX})
configure_file(main.cpp.in main.cpp)
add_executable(test-conda-relocate main.cpp)
install(TARGETS test-conda-relocate DESTINATION bin)
