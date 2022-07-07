# - Find the readline library
# This module defines
#  READLINE_INCLUDE_DIR, path to readline/readline.h, etc.
#  READLINE_LIBRARIES, the libraries required to use READLINE.
#  READLINE_FOUND, If false, do not try to use READLINE.
# also defined, but not for general use are
# READLINE_readline_LIBRARY, where to find the READLINE library.
# READLINE_ncurses_LIBRARY, where to find the ncurses library [might not be defined]

# Apple readline does not support readline hooks
# So we look for another one by default
if (APPLE)
  find_path(READLINE_INCLUDE_DIR NAMES readline/readline.h
            PATHS /sw/include
                  /opt/local/include
                  /opt/include
                  /usr/local/include
                  /usr/include/
            NO_DEFAULT_PATH)
endif ()
              
find_path(READLINE_INCLUDE_DIR NAMES readline/readline.h)

# Apple readline does not support readline hooks
# So we look for another one by default
if (APPLE)
  find_library(READLINE_readline_LIBRARY NAMES readline
               PATHS /sw/lib
                     /opt/local/lib
                     /opt/lib
                     /usr/local/lib
                     /usr/lib
               NO_DEFAULT_PATH)
endif ()

find_library(READLINE_readline_LIBRARY NAMES readline)

# Sometimes readline really needs ncurses
if (APPLE)
  find_library(READLINE_ncurses_LIBRARY NAMES ncurses
               PATHS /sw/lib
                     /opt/local/lib
                     /opt/lib
                     /usr/local/lib
                     /usr/lib
               NO_DEFAULT_PATH)
endif ()

find_library(READLINE_ncurses_LIBRARY NAMES ncurses)

mark_as_advanced(READLINE_INCLUDE_DIR
                 READLINE_readline_LIBRARY
                 READLINE_ncurses_LIBRARY)

set(READLINE_FOUND "NO")
               
if (READLINE_INCLUDE_DIR)
  if (READLINE_readline_LIBRARY)
    set(READLINE_FOUND "YES")
    set(READLINE_LIBRARIES ${READLINE_readline_LIBRARY})
    
    # some readline libraries depend on ncurses
    if (READLINE_ncurses_LIBRARY)
      set(READLINE_LIBRARIES ${READLINE_LIBRARIES} ${READLINE_ncurses_LIBRARY})
    endif ()
  endif ()
endif ()

if (READLINE_FOUND)
  message(STATUS "Found readline library")
else ()
  if (READLINE_FIND_REQUIRED)
    message(FATAL_ERROR "Could not find readline -- please give some paths to CMake")
  endif ()
endif ()
