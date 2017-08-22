rem This should be uncommented when conda-build supports compiler activation at test time for Windows.

rem echo project (my_sundials_test)>CMakeLists.txt
rem echo include_directories ("$ENV{PREFIX}/include") >>CMakeLists.txt
rem echo add_executable (cvRoberts_dns cvRoberts_dns.c) >>CMakeLists.txt
rem echo target_link_libraries (cvRoberts_dns LINK_PUBLIC m sundials_cvode openblas sundials_nvecserial) >>CMakeLists.txt
rem echo enable_testing() >>CMakeLists.txt
rem echo add_test (test_roberts cvRoberts_dns) >>CMakeLists.txt

rem cmake -G "NMake Makefiles" .
rem nmake 
rem ctest
