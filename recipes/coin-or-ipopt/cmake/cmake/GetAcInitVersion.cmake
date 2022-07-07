# Read the package version number specified as the second argument
# to the AC_INIT macro in a GNU Autoconf configure.in file.
#
# Input parameter:
# FileName: path to configure.ac file
#
# Define the following variables:
# VERSION_STRING:  The second argument to AC_INIT
# MAJOR_VERSION:   For a version string of the form m.n.p..., m
# MINOR_VERSION:   For a version string of the form m.n.p..., n
# PATCH_VERSION:   For a version string of the form m.n.p..., p

macro(get_ac_init_version FileName Prefix)
  file(READ ${FileName} configure_IN)
  # AC_INIT([Cbc],[2.9.8],[cbc@lists.coin-or.org])
  #string(REGEX REPLACE "(AC_INIT\\(\\[Cbc\\],\\[)(.*)(\\],\\[cbc@lists.coin-or.org\\]\\).*)" "\\2" configure_REGEX ${configure_IN})
  string(REGEX REPLACE "(AC_INIT.*)" "\\1" configure_REGEX ${configure_IN})
  
  string(REGEX REPLACE "^.*AC_INIT *\\([^,]+, *\\[([^, )]+)\\].*$" "\\1" ${Prefix}_VERSION_STRING "${configure_REGEX}")
  if (${Prefix}_VERSION_STRING STREQUAL "trunk")
    set(${Prefix}_MAJOR_VERSION "9")
    set(${Prefix}_MINOR_VERSION "9")
    set(${Prefix}_PATCH_VERSION "9999")
  else ()
    message(STATUS "${Prefix}_VERSION_STRING = ${${Prefix}_VERSION_STRING}")
    
    string(REGEX REPLACE "^([0-9]+)(\\..*)?$" "\\1" ${Prefix}_MAJOR_VERSION "${${Prefix}_VERSION_STRING}")
    string(REGEX REPLACE "^[0-9]+\\.([0-9]+)(\\..*)?$" "\\1" ${Prefix}_MINOR_VERSION "${${Prefix}_VERSION_STRING}")
    if (${Prefix}_VERSION_STRING MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+.*$")
      string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*$" "\\1" ${Prefix}_PATCH_VERSION "${${Prefix}_VERSION_STRING}")
    else ()
      set(${Prefix}_PATCH_VERSION "0")
    endif ()
  endif ()
endmacro ()
