message(STATUS "Attempting to create uninstall target for make")

set(INSTALL_MANIFEST_PATH "${CMAKE_CURRENT_BINARY_DIR}/install_manifest.txt")

if (EXISTS ${INSTALL_MANIFEST_PATH})
  message(STATUS "install_manifest.txt found")
  
  file(STRINGS ${INSTALL_MANIFEST_PATH} FILES_TO_REMOVE)
  
  foreach(FILE_TO_REMOVE ${FILES_TO_REMOVE})
    if (EXISTS ${FILE_TO_REMOVE})
      exec_program(${CMAKE_COMMAND} ARGS "-E remove \"${FILE_TO_REMOVE}\""
	           OUTPUT_VARIABLE STDOUT
		   RETURN_VALUE EXIT_CODE)
      
      if (${EXIT_CODE} EQUAL 0)
	message(STATUS "Successfully removed file ${FILE_TO_REMOVE}")
      else ()
	message(FATAL_ERROR "Failed to remove file ${FILE_TO_REMOVE} with error code ${EXIT_CODE}")
      endif ()
    else ()
      message(WARNING "Could not find file ${FILE_TO_REMOVE}")
    endif ()
  endforeach(FILE_TO_REMOVE)
else ()
  message(FATAL_ERROR "Could not find install manifest at ${CMAKE_CURRENT_BINARY_DIR}/install_manifest.txt\nThis may be because 'make install' has non been run or install_manifest.txt has been deleted")
endif ()
