# - Try to find Netcdf

function(get_netcdf_libs ncpath nfpath)

  set(ncconfig ${ncpath}/bin/nc-config)
  set(nfconfig ${nfpath}/bin/nf-config)

  # Get C libs
  if (EXISTS ${ncconfig})
    execute_process(COMMAND ${ncconfig} --libs OUTPUT_VARIABLE nclibs OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif()

  # Fall back to find_library
  if (NOT nclibs)
    find_library(nclibs_temp netcdf REQUIRED HINTS ${ncpath}/lib ${ncpath}/lib64)
    set(nclibs ${nclibs_temp})
  endif()

  # Get fortran libs
  if (EXISTS ${nfconfig})
    execute_process(COMMAND ${nfconfig} --flibs OUTPUT_VARIABLE nflibs OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif()

  if (NOT nflibs)
    find_library(nflibs_temp netcdff REQUIRED HINTS ${nfpath}/lib ${nfpath}/lib64)
    set(nflibs ${nflibs_temp})
  endif()

  set(netcdf_c_libs ${nclibs} PARENT_SCOPE)
  set(netcdf_f_libs ${nflibs} PARENT_SCOPE)
endfunction()

function(create_netcdf_target)

  # Grab things from env
  set(NETCDF_PATH         $ENV{NETCDF_PATH})
  set(NETCDF_C_PATH       $ENV{NETCDF_C_PATH})
  set(NETCDF_FORTRAN_PATH $ENV{NETCDF_FORTRAN_PATH})

  if (NETCDF_C_PATH)
    # Sanity checks
    if (NOT NETCDF_FORTRAN_PATH)
      message(FATAL_ERROR "NETCDF_C_PATH specified without NETCDF_FORTRAN_PATH")
    endif()
    if (NOT EXISTS ${NETCDF_C_PATH}/lib AND NOT EXISTS ${NETCDF_C_PATH}/lib64)
      message(FATAL_ERROR "NETCDF_C_PATH does not contain a lib or lib64 directory")
    endif ()
    if (NOT EXISTS ${NETCDF_FORTRAN_PATH}/lib AND NOT EXISTS ${NETCDF_FORTRAN_PATH}/lib64)
      message(FATAL_ERROR "NETCDF_FORTRAN_PATH does not contain a lib or lib64 directory")
    endif ()

    get_netcdf_libs(${NETCDF_C_PATH} ${NETCDF_FORTRAN_PATH})
    find_path (netcdf_c_incdir netcdf.h REQUIRED HINTS ${NETCDF_C_PATH}/include)
    find_path (netcdf_f_incdir netcdf.inc REQUIRED HINTS ${NETCDF_FORTRAN_PATH}/include)

  elseif (NETCDF_FORTRAN_PATH)
    message(FATAL_ERROR "NETCDF_FORTRAN_PATH specified without NETCDF_C_PATH")

  elseif (NETCDF_PATH)
    # Sanity checks
    if (NOT EXISTS ${NETCDF_PATH}/lib AND NOT EXISTS ${NETCDF_PATH}/lib64)
      message(FATAL_ERROR "NETCDF_PATH does not contain a lib or lib64 directory")
    endif ()

    get_netcdf_libs(${NETCDF_PATH} ${NETCDF_PATH})
    find_path(netcdf_c_incdir netcdf.h REQUIRED HINTS ${NETCDF_PATH}/include)
    find_path(netcdf_f_incdir netcdf.inc REQUIRED HINTS ${NETCDF_PATH}/include)

  else()
    message(FATAL_ERROR "NETCDF not found: Define NETCDF_PATH or NETCDF_C_PATH and NETCDF_FORTRAN_PATH in config_machines.xml or config_compilers.xml")
  endif()

  set(netcdf_c_incdir ${netcdf_c_incdir})
  set(netcdf_f_incdir ${netcdf_f_incdir})
  set(netcdf_c_libs ${netcdf_c_libs} PARENT_SCOPE)
  set(netcdf_f_libs ${netcdf_f_libs} PARENT_SCOPE)
  endfunction()

create_netcdf_target()
