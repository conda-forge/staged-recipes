# coin_check_and_add_include_path: check if ${dir}/include is a path and exists
# dir must be a variable containing "None" or a path
macro(coin_check_and_add_include_path dir)
  if (NOT ${dir} STREQUAL "None")
    if (NOT EXISTS "${${dir}}")
      message(FATAL_ERROR "Error: ${dir} = ${${dir}} which is not an existing directory")
    else ()
      include_directories(${${dir}})
    endif ()
  endif ()
endmacro ()

# coin_check_and_add_library_path: check if ${dir}/lib is a path and exists
# dir must be a variable containing "None" or a path
macro(coin_check_and_add_library_path dir)
  if (NOT ${dir} STREQUAL "None")
    if (NOT EXISTS "${${dir}}")
      message(FATAL_ERROR "Error: ${dir} = ${${dir}} which is not an existing directory")
    else ()
      link_directories(${${dir}})
    endif ()
  endif ()
endmacro ()

# coin_check_and_add_include_library_path: check if ${dir}/lib and ${dir}/include are pathes and exists
# dir must be a variable containing "None" or a path
macro(coin_check_and_add_include_library_path dir)
  if (NOT ${dir} STREQUAL "None")
    if (NOT EXISTS "${${dir}}/include")
      message(FATAL_ERROR "Error: ${dir} = ${${dir}}/include which is not an existing directory")
    else ()
      include_directories(${${dir}}/include)
    endif ()
    
    if (NOT EXISTS "${${dir}}/lib")
      message(FATAL_ERROR "Error: ${dir} = ${${dir}}/lib which is not an existing directory")
    else ()
      link_directories(${${dir}}/lib)
    endif ()
  endif ()
endmacro()

#
# macros to manage files and version
#

macro(add_source_files ListFiles FilesToInclude Version VersionToCheck)
  if (("${${Version}}" VERSION_GREATER "${VersionToCheck}") OR ("${${Version}}" VERSION_EQUAL "${VersionToCheck}"))
    set(${ListFiles} ${${ListFiles}}
                     ${${FilesToInclude}})
  endif ()
endmacro()

macro(remove_source_files ListFiles FilesToExclude Version VersionToCheck)
  if (("${${Version}}" VERSION_EQUAL "${VersionToCheck}") OR ("${${Version}}" VERSION_GREATER "${VersionToCheck}"))
    foreach(Item IN LIST ${FilesToExclude})
      list(REMOVE_ITEM ${ListFiles} ${Item})
    endforeach()
  endif ()
endmacro()

#
# macros for tests
#

find_package(PythonInterp REQUIRED)

set(COIN_TEST_LOG_DIR  "${CMAKE_BINARY_DIR}/tests" CACHE PATH "The log and output directory for tests")

mark_as_advanced(COIN_TEST_LOG_DIR)

if (NOT EXISTS ${CMAKE_BINARY_DIR}/CoinTests)
  make_directory(${CMAKE_BINARY_DIR}/CoinTests)
endif ()

if (NOT EXISTS ${COIN_TEST_LOG_DIR})
  make_directory(${COIN_TEST_LOG_DIR})
endif ()

# add_coin_test: generate a cmake wrapper around cbc / clp executable and then add the test
# SolverName: the name of the solver. Will be appended to the out and log filename (must have the same name as the built target)
# Name: the name of the test
# FileData: the name of the mps / lp data file

macro(add_coin_test Name SolverName FileData)
  if (WIN32)
    file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat "cmd.exe /C \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${SolverName} ${FileData} %COIN_EXE_OPTIONS% -solution ${COIN_TEST_LOG_DIR}/${Name}.out -solve > ${COIN_TEST_LOG_DIR}/${Name}.log 2>&1 \"")
    
    add_test(NAME ${Name}
             COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat)
  else ()
    file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh "sh -c \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${SolverName} ${FileData} $COIN_EXE_OPTIONS -solution ${COIN_TEST_LOG_DIR}/${Name}.out -solve > ${COIN_TEST_LOG_DIR}/${Name}.log 2>&1 \"")
    
    execute_process(COMMAND chmod a+x ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
    add_test(NAME ${Name}
             COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
  endif ()
  
  if (WIN32)
    # Escape each ';' in the %PATH% environment variable
    string(REGEX REPLACE "\\\\" "/" WINPATH "$ENV{PATH}")
    string(REGEX REPLACE "\;" "\\\\;" WINPATH "${WINPATH}")
      
    set(ENV_COIN_TESTS "PATH=${WINPATH}\\;${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/lib\\;${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/bin")
    set_tests_properties(${Name} PROPERTIES ENVIRONMENT "PATH=${ENV_COIN_TESTS}")
  endif ()
endmacro()

# add_coin_test_list: generate a cmake wrapper around cbc / clp executable and then add the test
# SolverName: the name of the solver. Will be appended to the out and log filename (must have the same name as the built target)
# Prefix: a prefix which will be added to the test name
# Suffix: a suffix which will be added to the test name
# FileList: the list of test file
# Label: a default label to tag tests
# Timeout: a dafault timeout for tests
macro(add_coin_test_list SolverName Prefix Suffix FileList Label Timeout)
  foreach(File ${${FileList}})
    get_filename_component(_NAME ${File} NAME)
    string(REGEX REPLACE "[\\.]" "_" _NAME "${_NAME}")
    
    add_coin_test(${Prefix}_${_NAME}_${Suffix} ${SolverName} ${File})

    if (NOT COIN_TESTS_DISABLE_TIMEOUT)
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT ${Timeout})
    else ()
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT 1000000)
    endif ()
    set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES LABELS "${Label}")
  endforeach ()
endmacro()

# add_coin_sym_test: generate a cmake wrapper around symphony executable and then add the test
# SolverName: the name of the solver. Will be appended to the out and log filename (must have the same name as the built target)
# Name: the name of the test
# FileData: the name of the mps / lp data file

macro(add_coin_sym_test Name SolverName FileData)
  if (WIN32)
    file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat "cmd.exe /C \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/symphony.exe -F ${FileData} %COIN_EXE_OPTIONS% > ${COIN_TEST_LOG_DIR}/${Name}.log 2>&1 \"")
    
    add_test(NAME ${Name}
             COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat)
  else ()
    file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh "sh -c \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/symphony -F ${FileData} $COIN_EXE_OPTIONS > ${COIN_TEST_LOG_DIR}/${Name}.log 2>&1 \"")
    
    execute_process(COMMAND chmod a+x ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
    add_test(NAME ${Name}
             COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
  endif ()
  
  if (WIN32)
    # Escape each ';' in the %PATH% environment variable
    string(REGEX REPLACE "\\\\" "/" WINPATH "$ENV{PATH}")
    string(REGEX REPLACE "\;" "\\\\;" WINPATH "${WINPATH}")
      
    set(ENV_COIN_TESTS "PATH=${WINPATH}\\;${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/lib\\;${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/bin")
    set_tests_properties(${Name} PROPERTIES ENVIRONMENT "PATH=${ENV_COIN_TESTS}")
  endif ()
endmacro()

# add_coin_sym_test_list: generate a cmake wrapper around symphony executable and then add the test
# SolverName: the name of the solver. Will be appended to the out and log filename (must have the same name as the built target)
# Prefix: a prefix which will be added to the test name
# Suffix: a suffix which will be added to the test name
# FileList: the list of test file
# Label: a default label to tag tests
# Timeout: a dafault timeout for tests
macro(add_coin_sym_test_list SolverName Prefix Suffix FileList Label Timeout)
  foreach(File ${${FileList}})
    get_filename_component(_NAME ${File} NAME)
    string(REGEX REPLACE "[\\.]" "_" _NAME "${_NAME}")
    
    add_coin_sym_test(${Prefix}_${_NAME}_${Suffix} ${SolverName} ${File})

    if (NOT COIN_TESTS_DISABLE_TIMEOUT)
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT ${Timeout})
    else ()
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT 1000000)
    endif ()
    set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES LABELS "${Label}")
  endforeach ()
endmacro()

# add_coin_vol_test: generate a cmake wrapper for Vol and then add the test
# SolverName: the name of the solver. Will be appended to the out and log filename (must have the same name as the built target)
# Name: the name of the test
# FileData: the name of the mps / lp data file

macro(add_coin_vol_test Name SolverName FileData)
  if (WIN32)
    file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat "cmd.exe /C \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/vollp.exe -F ${FileData} > ${COIN_TEST_LOG_DIR}/${Name}.log 2>&1 \"")
    
    add_test(NAME ${Name}
             COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat)
  else ()
    file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh "sh -c \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/vollp -F ${FileData} > ${COIN_TEST_LOG_DIR}/${Name}.log 2>&1 \"")
    
    execute_process(COMMAND chmod a+x ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
    add_test(NAME ${Name}
             COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
  endif ()
  
  if (WIN32)
    # Escape each ';' in the %PATH% environment variable
    string(REGEX REPLACE "\\\\" "/" WINPATH "$ENV{PATH}")
    string(REGEX REPLACE "\;" "\\\\;" WINPATH "${WINPATH}")
      
    set(ENV_COIN_TESTS "PATH=${WINPATH}\\;${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/lib\\;${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/bin")
    set_tests_properties(${Name} PROPERTIES ENVIRONMENT "PATH=${ENV_COIN_TESTS}")
  endif ()
endmacro()

# add_coin_vol_test_list: generate a cmake wrapper around osi_vol executable and then add the test
# Prefix: a prefix which will be added to the test name
# Suffix: a suffix which will be added to the test name
# FileList: the list of test file
# Label: a default label to tag tests
# Timeout: a dafault timeout for tests
macro(add_coin_vol_test_list Prefix Suffix FileList Label Timeout)
  foreach(File ${${FileList}})
    get_filename_component(_NAME ${File} NAME)
    string(REGEX REPLACE "[\\.]" "_" _NAME "${_NAME}")
    
    add_coin_test(${Prefix}_${_NAME}_${Suffix} osi_vol ${File})

    if (NOT COIN_TESTS_DISABLE_TIMEOUT)
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT ${Timeout})
    else ()
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT 1000000)
    endif ()
    set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES LABELS "${Label}")
  endforeach ()
endmacro()

# add_coin_dylp_test: generate a cmake wrapper around osi_dylp executable and then add the test
# SolverName: the name of the solver. Will be appended to the out and log filename (must have the same name as the built target)
# Name: the name of the test
# FileData: the name of the mps / lp data file

macro(add_coin_dylp_test Name SolverName FileData)
  if (NOT EXISTS ${CMAKE_BINARY_DIR}/tmp)
    make_directory(${CMAKE_BINARY_DIR}/tmp)
  endif ()
  
  get_filename_component(FileData_EXT ${FileData} EXT)
  get_filename_component(FileData_NAME ${FileData} NAME)
  
  if ((FileData_EXT STREQUAL ".mps.gz") OR (FileData_EXT STREQUAL ".lp.gz") OR (FileData_EXT STREQUAL ".gz"))
    string(REGEX REPLACE ".gz" "" FileData_NAME_NOGZ ${FileData_NAME})
    
    if (WIN32)
      file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat
           "cmd.exe /C \"${CMAKE_COMMAND} -E copy ${FileData} ${CMAKE_BINARY_DIR}/tmp "
           " && gunzip.exe -f ${CMAKE_BINARY_DIR}/tmp/${FileData_NAME} "
           " && ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/osi_dylp.exe -L ${COIN_TEST_LOG_DIR}/${Name}.log -e ${CMAKE_CURRENT_SOURCE_DIR}/DyLP/src/Dylp/dy_errmsgs.txt ${CMAKE_BINARY_DIR}/tmp/${FileData_NAME_NOGZ})\"")
      
      add_test(NAME ${Name}
               COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat)
    else ()
      file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh
           "sh -c \"${CMAKE_COMMAND} -E copy ${FileData} ${CMAKE_BINARY_DIR}/tmp "
           " && gunzip -f ${CMAKE_BINARY_DIR}/tmp/${FileData_NAME} "
           " && ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/osi_dylp -L ${COIN_TEST_LOG_DIR}/${Name}.log -e ${CMAKE_CURRENT_SOURCE_DIR}/DyLP/src/Dylp/dy_errmsgs.txt ${CMAKE_BINARY_DIR}/tmp/${FileData_NAME_NOGZ})\"")
      
      execute_process(COMMAND chmod a+x ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
      add_test(NAME ${Name}
               COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
    endif ()
  else ()
    if (WIN32)
      file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat
           "cmd /C \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/osi_dylp.exe -L ${COIN_TEST_LOG_DIR}/${Name}.log -e ${CMAKE_CURRENT_SOURCE_DIR}/DyLP/src/Dylp/dy_errmsgs.txt ${FileData})\"")

      add_test(NAME ${Name}
               COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.bat)
    else ()
      file(WRITE ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh
           "sh -c \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/osi_dylp -L ${COIN_TEST_LOG_DIR}/${Name}.log -e ${CMAKE_CURRENT_SOURCE_DIR}/DyLP/src/Dylp/dy_errmsgs.txt ${FileData})\"")
      
      execute_process(COMMAND chmod a+x ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
      add_test(NAME ${Name}
               COMMAND ${CMAKE_BINARY_DIR}/CoinTests/${Name}_${SolverName}.sh)
    endif ()
  endif ()
  
  if (WIN32)
    # Escape each ';' in the %PATH% environment variable
    string(REGEX REPLACE "\\\\" "/" WINPATH "$ENV{PATH}")
    string(REGEX REPLACE "\;" "\\\\;" WINPATH "${WINPATH}")
      
    set(ENV_COIN_TESTS "PATH=${WINPATH}\\;${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/lib\\;${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/bin")
    set_tests_properties(${Name} PROPERTIES ENVIRONMENT "PATH=${ENV_COIN_TESTS}")
  endif ()
endmacro()

# add_coin_dylp_test_list: generate a cmake wrapper around osi_dylp executable and then add the test
# Prefix: a prefix which will be added to the test name
# Suffix: a suffix which will be added to the test name
# FileList: the list of test file
# Label: a default label to tag tests
# Timeout: a dafault timeout for tests
macro(add_coin_dylp_test_list Prefix Suffix FileList Label Timeout)
  foreach(File ${${FileList}})
    get_filename_component(_NAME ${File} NAME)
    string(REGEX REPLACE "[\\.]" "_" _NAME "${_NAME}")
    
    add_coin_test(${Prefix}_${_NAME}_${Suffix} osi_dylp ${File})

    if (NOT COIN_TESTS_DISABLE_TIMEOUT)
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT ${Timeout})
    else ()
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT 1000000)
    endif ()
    set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES LABELS "${Label}")
  endforeach ()
endmacro()

# create_log_analysis: build a log analysis test for one solver. The string FAILED is returned is case of failure and PASSED in case of success
# - Name: a value corresponding to the name of the test
# - AdditionalName: a value corresponding to the suffix name of the test
# - TestRegex: the regex to be extracted with <number> where the result must be found
# - TestRefVal: the reference result
# - TestRelLevel: the test threshold
macro(create_log_analysis Name AdditionalName TestRegex TestRefVal TestRelLevel)
  add_test(NAME ${Name}_${AdditionalName}
           WORKING_DIRECTORY ${BinTestPath}
           COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/parse_results.py ${COIN_TEST_LOG_DIR}/${Name}.log ${TestRegex} ${TestRefVal} ${TestRelLevel})
    
  set_tests_properties(${Name}_${AdditionalName} PROPERTIES DEPENDS "${TestName}_${TestSolverName}")
  set_tests_properties(${Name}_${AdditionalName} PROPERTIES ENVIRONMENT "${TEST_ENV_VAR}")
  set_tests_properties(${Name}_${AdditionalName} PROPERTIES PASS_REGULAR_EXPRESSION "PASSED")
  set_tests_properties(${Name}_${AdditionalName} PROPERTIES LABELS "ANALYSIS")
endmacro()

# From hydrogen CMakeLists.txt file
string( ASCII 27 _escape)

set(color_black    "${_escape}[0;30m") # Black - Regular
set(color_red      "${_escape}[0;31m") # Red
set(color_green    "${_escape}[0;32m") # Green
set(color_yellow   "${_escape}[0;33m") # Yellow
set(color_blue     "${_escape}[0;34m") # Blue
set(color_purple   "${_escape}[0;35m") # Purple
set(color_cyan     "${_escape}[0;36m") # Cyan
set(color_white    "${_escape}[0;37m") # White
set(color_bblack   "${_escape}[1;30m") # Black - Bold
set(color_bred     "${_escape}[1;31m") # Red
set(color_bgreen   "${_escape}[1;32m") # Green
set(color_byellow  "${_escape}[1;33m") # Yellow
set(color_bblue    "${_escape}[1;34m") # Blue
set(color_bpurple  "${_escape}[1;35m") # Purple
set(color_bcyan    "${_escape}[1;36m") # Cyan
set(color_bwhite   "${_escape}[1;37m") # White
set(color_ublack   "${_escape}[4;30m") # Black - Underline
set(color_ured     "${_escape}[4;31m") # Red
set(color_ugreen   "${_escape}[4;32m") # Green
set(color_uyellow  "${_escape}[4;33m") # Yellow
set(color_ublue    "${_escape}[4;34m") # Blue
set(color_upurple  "${_escape}[4;35m") # Purple
set(color_ucyan    "${_escape}[4;36m") # Cyan
set(color_uwhite   "${_escape}[4;37m") # White
set(color_bgblack  "${_escape}[40m")   # Black - Background
set(color_bgred    "${_escape}[41m")   # Red
set(color_bggreen  "${_escape}[42m")   # Green
set(color_bgyellow "${_escape}[43m")   # Yellow
set(color_bgblue   "${_escape}[44m")   # Blue
set(color_bgpurple "${_escape}[45m")   # Purple
set(color_bgcyan   "${_escape}[46m")   # Cyan
set(color_bgwhite  "${_escape}[47m")   # White
set(color_reset    "${_escape}[0m")    # Text Reset

# Example of use:
# COLOR_MESSAGE("${color_cyan}Installation Summary${color_reset}")

function(COLOR_MESSAGE TEXT)
  if (CMAKE_COLOR_MAKEFILE AND NOT WIN32)
    message(${TEXT})
  else ()
    string(REGEX REPLACE "${_escape}[\\[0123456789;]*m" "" __TEXT ${TEXT})
    message("${__TEXT} ")
  endif ()
endfunction ()

# add_regex: allow to concat several regex into one for using it with cmake
macro(add_regex VARIABLE REGEX)
  set(${VARIABLE} "${${VARIABLE}}${REGEX}.*")
endmacro ()

# Example of use:
#
# set(TEST_REGEX "")
# add_regex(TEST_REGEX "INFO  : Overall capacity cost : 7.54846e[+]09" )
# add_regex(TEST_REGEX "INFO  : Overall simulation cost : 3.40945e[+]09")
# add_regex(TEST_REGEX "INFO  : Overall reward : -1.09579e[+]10" )
# set_tests_properties(Test_Name PROPERTIES PASS_REGULAR_EXPRESSION "${TEST_REGEX}" )

#
# macros to manage files and version
#

# add_source_files(ListFiles FilesToInclude VersionRef VersionToCheck)
# ListFiles: a variable name which will contain the resulting list of files
# FilesToInclude: a variable name containing a list of files to be included
# VersionRef: a string containing the reference version (above or equal to this version, the files are included in the resulting list)
# VersionToCheck: a string containing the test version. If the version is above or equal to this version, the files are included in the resulting list
macro(add_source_files ListFiles FilesToInclude VersionRef VersionToCheck)
  if (("${VersionToCheck}" VERSION_GREATER "${VersionRef}") OR ("${VersionToCheck}" VERSION_EQUAL "${VersionRef}"))
    set(${ListFiles} ${${ListFiles}}
                     ${FilesToInclude})
  endif ()
endmacro()

# remove_source_files(ListFiles FilesToExclude VersionRef VersionToCheck)
# ListFiles: a variable name which will contain the resulting list of files
# FilesToInclude: a variable name containing a list of files to be excluded
# VersionRef: a string containing the reference version (above or equal to this version, the files are excluded from the resulting list)
# VersionToCheck: a string containing the test version. If the version is above or equal to this version, the files are excluded from the resulting list
macro(remove_source_files ListFiles FilesToExclude VersionRef VersionToCheck)
  if (("${VersionToCheck}" VERSION_GREATER "${VersionRef}") OR ("${VersionToCheck}" VERSION_EQUAL "${VersionRef}"))
    set(TMP_LIST ${FilesToExclude})
    #foreach(Item ${TMP_LIST})
    foreach(Item IN LISTS TMP_LIST)
      list(REMOVE_ITEM ${ListFiles} ${Item})
    endforeach()
  endif ()
endmacro()

#
# How to use these macros:
#
#
# set(LIST_SRCS file1.cpp
#               file2.cpp
#               file3.cpp)
# 
# set(LIST_TO_ADD_SRCS file4.cpp
#                      file5.cpp
#                      file6.cpp)
# 
# set(VERSION "1.1")
# 
# add_source_files(LIST_SRCS "${LIST_TO_ADD_SRCS}" "1.0" "${VERSION}")
# 
# set(LIST_TO_ADD_SRCS file7.cpp)
# 
# set(VERSION "0.9")
# 
# add_source_files(LIST_SRCS "${LIST_TO_ADD_SRCS}" "1.0" "${VERSION}")
# 
# message(STATUS "RESULT: ADD - LIST_SRCS = ${LIST_SRCS}")
# 
# set(LIST_TO_REMOVE_SRCS file4.cpp)
# 
# set(VERSION "1.1")
# 
# remove_source_files(LIST_SRCS LIST_TO_REMOVE_SRCS "1.0" "${VERSION}")
# 
# set(LIST_TO_REMOVE_SRCS file5.cpp)
# 
# set(VERSION "0.9")
# 
# remove_source_files(LIST_SRCS LIST_TO_REMOVE_SRCS "1.0" "${VERSION}")
# 
# message(STATUS "RESULT: REMOVE - LIST_SRCS = ${LIST_SRCS}")

macro(add_ipopt_test Name FileData)
  add_test(NAME ${Name}
           COMMAND ${CMAKE_BINARY_DIR}/bin/ipopt -- ${FileData})
endmacro()

macro(add_ipopt_test_list Prefix Suffix FileList Label Timeout)
  foreach(File ${${FileList}})
    string(REGEX REPLACE "[\\.]" "_" _NAME "${File}")
    string(REGEX REPLACE "[-]"   "_" _NAME "${_NAME}")
    string(REGEX REPLACE "[/]"   "_" _NAME "${_NAME}")

    add_ipopt_test(${Prefix}_${_NAME}_${Suffix} ${IPOPT_INSTANCES_DIR}/${File})

    if (NOT COIN_TESTS_DISABLE_TIMEOUT)
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT ${Timeout})
    else ()
      set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES TIMEOUT 1000000)
    endif ()
    set_tests_properties(${Prefix}_${_NAME}_${Suffix} PROPERTIES LABELS "${Label}")
  endforeach ()
endmacro()
