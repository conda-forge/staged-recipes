# nanocdr is header-only; upstream's CMakeLists does not install the header or a
# CMake package, so this recipe provides both.
if(NOT TARGET nanocdr::nanocdr)
  get_filename_component(_nanocdr_prefix "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)
  add_library(nanocdr::nanocdr INTERFACE IMPORTED)
  set_target_properties(nanocdr::nanocdr PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_nanocdr_prefix}/include"
    INTERFACE_COMPILE_FEATURES cxx_std_17)
  unset(_nanocdr_prefix)
endif()
