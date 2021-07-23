# Adapted from the following links and pulling in options from old CROSSTOOL.template
# https://docs.bazel.build/versions/0.26.0/tutorial/cc-toolchain-config.html
# https://github.com/bazelbuild/bazel/blob/4dfc83d5f11e9190e9e25dee4c7dc2a71cd7b8fd/tools/osx/crosstool/cc_toolchain_config.bzl
# https://docs.bazel.build/versions/master/skylark/lib/cc_common.html#create_cc_toolchain_config_info

load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
     "feature",
     "flag_group",
     "flag_set",
     "tool_path",
     "with_feature_set",
     )

load("@bazel_tools//tools/build_defs/cc:action_names.bzl",
     "ACTION_NAMES")

def _impl(ctx):
    tool_paths = [
        tool_path(
            name = "gcc",
            path = "${GCC}",
        ),
        tool_path(
            name = "ld",
            path = "${LD}",
        ),
        tool_path(
            name = "ar",
            path = "${CONDA_PREFIX}/bin/${AR}",
        ),
        tool_path(
            name = "cpp",
            path = "/usr/bin/cpp",
        ),
        tool_path(
            name = "gcov",
            path = "/usr/bin/gcov",
        ),
        tool_path(
            name = "nm",
            path = "${NM}",
        ),
        tool_path(
            name = "objdump",
            path = "/usr/bin/objdump",
        ),
        tool_path(
            name = "strip",
            path = "${STRIP}",
        ),
    ]

    all_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.clif_match,
        ACTION_NAMES.lto_backend,
    ]

    all_cpp_compile_actions = [
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.clif_match,
    ]

    preprocessor_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.clif_match,
    ]

    codegen_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.lto_backend,
    ]

    all_link_actions = [
        ACTION_NAMES.cpp_link_executable,
        ACTION_NAMES.cpp_link_dynamic_library,
        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ]

    compiler_flags = feature(
        name = "compiler_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [flag_group(flags = "${CFLAGS} ${CPPFLAGS}".split(" "))],
            ),
        ],
    )

    objcpp_flags = feature(
        name = "objcpp_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.objcpp_compile,
                ],
                flag_groups = [flag_group(flags = "${CXXFLAGS} ${CPPFLAGS}".split(" "))],
            ),
        ],
    )

    cxx_flags = feature(
        name = "cxx_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [flag_group(flags = "${CXXFLAGS} ${CPPFLAGS}".split(" "))],
            ),
        ],
    )
    
    if "TARGET_PLATFORM".startswith("osx"):
        toolchain_include_directories_flags = [
            "-isystem",
            "${CONDA_PREFIX}/include/c++/v1",
            "-isystem",
            "${CONDA_PREFIX}/lib/clang/${COMPILER_VERSION}/include",
            "-isystem",
            "${CONDA_BUILD_SYSROOT}/usr/include",
            "-isystem",
            "${CONDA_BUILD_SYSROOT}/System/Library/Frameworks",
            "-isystem",
            "${PREFIX}/include",
        ]
    else:
        toolchain_include_directories_flags = [
            "-isystem",
            "${PREFIX}/include",
        ]

    toolchain_include_directories_feature = feature(
        name = "toolchain_include_directories",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = toolchain_include_directories_flags,
                    ),
                ],
            ),
        ],
    )

    linker_flags = feature(
        name = "linker_flags",
        flag_sets = [
            flag_set (
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.objcpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [flag_group(flags = "-l${LIBCXX} ${LDFLAGS}".split(" "))],
            ),
        ],
    )

    link_libcpp_feature = feature(
        name = "link_libc++",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions +
                          ["objc-executable", "objc++-executable"],
                flag_groups = [flag_group(flags = "-l${LIBCXX} ${LDFLAGS}".split(" "))],
            ),
        ],
    )

    supports_pic_feature = feature(
        name = "supports_pic",
        enabled = True
        )

    supports_dynamic_linker = feature(
        name = "supports_dynamic_linker",
        enabled = True
        )

    opt = feature(
        name = "opt",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-g0",
                            "-O2",
                            "-D_FORTIFY_SOURCE=1",
                            "-DNDEBUG",
                            "-ffunction-sections",
                            "-fdata-sections",
                        ],
                    ),
                ],
            ),
        ],
    )

    dbg = feature(
        name = "dbg",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-g"
                        ],
                    ),
                ],
            ),
        ],
    )

    if "TARGET_PLATFORM".startswith("osx"):
        cxx_builtin_include_directories = [
            "${CONDA_BUILD_SYSROOT}/System/Library/Frameworks",
            "${CONDA_BUILD_SYSROOT}/usr/include",
            "${CONDA_PREFIX}/lib/clang/${COMPILER_VERSION}/include",
            "${CONDA_PREFIX}/include/c++/v1",
            "${PREFIX}/include",
            "${HOST_PREFIX}/include",
        ]
    else:
        cxx_builtin_include_directories = [
            "${CONDA_BUILD_SYSROOT}/usr/include",
	    "${CONDA_PREFIX}/lib/gcc/${HOST}/${COMPILER_VERSION}",
	    "${CONDA_PREFIX}/${HOST}/include/c++/${COMPILER_VERSION}",
            "${PREFIX}/include",
        ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "local",
	host_system_name = "local",
        #host_system_name = "TARGET_CPU",
        target_system_name = "TARGET_SYSTEM",
        target_cpu = "TARGET_CPU",
        target_libc = "TARGET_LIBC",
        compiler = "compiler",
        abi_version = "local",
        abi_libc_version = "local",
        tool_paths = tool_paths,
        cxx_builtin_include_directories = cxx_builtin_include_directories,
        features = [toolchain_include_directories_feature, compiler_flags, cxx_flags, supports_pic_feature, linker_flags, supports_dynamic_linker, link_libcpp_feature, objcpp_flags],
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
