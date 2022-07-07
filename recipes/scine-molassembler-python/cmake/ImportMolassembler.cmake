macro(import_molassembler)
  # If the target already exists, do nothing
  if(NOT TARGET Scine::Molassembler)
    # Try to find the package locally
    find_package(ScineMolassembler QUIET)
    if(TARGET Scine::Molassembler)
      message(STATUS "Scine::Molassembler found locally at ${ScineMolassembler_DIR}")
    else()
      # Download it instead
      include(DownloadProject)
      download_project(
        PROJ scine-molassembler
        GIT_REPOSITORY      https://github.com/qcscine/molassembler.git
        GIT_TAG             1.2.0
        QUIET
      )
      # Note: Options defined in the project calling this function override default
      # option values specified in the imported project.
      add_subdirectory(${scine-molassembler_SOURCE_DIR} ${scine-molassembler_BINARY_DIR})

      # Final check if all went well
      if(TARGET Scine::Molassembler)
        message(STATUS
          "Scine::Molassembler was not found in your PATH, so it was downloaded."
        )
      else()
        string(CONCAT error_msg
          "Scine::Molassembler was not found in your PATH and could not be established "
          "through a download. Try specifying Scine_DIR or altering "
          "CMAKE_PREFIX_PATH to point to a candidate Scine installation base "
          "directory."
        )
        message(FATAL_ERROR ${error_msg})
      endif()
    endif()
  endif()
endmacro()
