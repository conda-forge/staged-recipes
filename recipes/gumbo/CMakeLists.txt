# From VCPKG: https://github.com/microsoft/vcpkg/blob/c3ef5d181bc47d13e1c329a54925e7342ddfb8ea/ports/gumbo/CMakeLists.txt
# Copyright (c) Microsoft Corporation
#
# All rights reserved.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


cmake_minimum_required(VERSION 3.8.0)

project(gumbo)

set(gumbo_srcs
  src/attribute.c
  src/char_ref.c
  src/error.c
  src/parser.c
  src/string_buffer.c
  src/string_piece.c
  src/tag.c
  src/tokenizer.c
  src/utf8.c
  src/util.c
  src/vector.c
)

include_directories(src)
if (MSVC)
  include_directories(visualc/include)
endif (MSVC)

add_library(gumbo ${gumbo_srcs})

install(
  TARGETS gumbo
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES  src/gumbo.h src/tag_enum.h DESTINATION include)
endif()