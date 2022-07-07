macro(VA_COPY)
  write_file("${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/cmake_try_compile.c"
    "#include <stdarg.h>
    void f (int i, ...) {
        va_list args1, args2;
        va_start (args1, i);
        va_copy (args2, args1);
        if (va_arg (args2, int) != 42 || va_arg (args1, int) != 42)
            exit (1);
        va_end (args1); va_end (args2);
    }
    int main() {
        f (0, 42);
        return 0;
    }")
  
  try_compile(IPOPT_HAS_VA_COPY ${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/cmake_try_compile.c)
  
  if (IPOPT_HAS_VA_COPY)
    set(VA_COPY va_copy CACHE STRING "va_copy function")
  else ()
    write_file("${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/cmake_try_compile.c"
      "#include <stdarg.h>
       void f (int i, ...) {
            va_list args1, args2;
            va_start (args1, i);
            __va_copy (args2, args1);
            if (va_arg (args2, int) != 42 || va_arg (args1, int) != 42)
                exit (1);
            va_end (args1); va_end (args2);
        }
        int main() {
            f (0, 42);
            return 0;
      }")

    try_compile(IPOPT_HAS_VA_COPY ${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/cmake_try_compile.c)
    
    if (HAVE___VA_COPY)
      set(_VA_COPY __va_copy CACHE STRING "va_copy function")
    endif ()
  endif()
endmacro()
