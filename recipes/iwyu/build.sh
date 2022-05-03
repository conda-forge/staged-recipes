#!/usr/bin/env bash
mkdir -p build
cd build

cmake \
  -G "Unix Makefiles" \
  ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE=release \
  -DCMAKE_C_COMPILER=${CC} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  ..

cmake --build .
cmake --install . -v

ctest \
  --output-on-failure \
  --exclude-regex "\
^cxx.test_badinc$\
|^cxx.test_badinc_extradef$\
|^cxx.test_fwd_decl_of_nested_class_defined_later$\
|^cxx.test_iterator$\
|^cxx.test_libbuiltins$\
|^cxx.test_no_char_traits$\
|^cxx.test_no_deque$\
|^cxx.test_no_fwd_decl_std$\
|^cxx.test_operator_new$\
|^cxx.test_overloaded_class$\
|^cxx.test_placement_new$\
|^cxx.test_precomputed_tpl_args$\
|^cxx.test_prefix_header_attribution$\
|^cxx.test_prefix_header_operator_new$\
|^cxx.test_quoted_includes_first$\
|^cxx.test_scope_crash$\
|^cxx.test_std_size_t$\
|^cxx.test_stl_container_provides_allocator$\
|^cxx.test_uses_printf$"

