package(default_visibility = ["//visibility:public"])

filegroup(
    name = "empty",
    srcs = [],
)

filegroup(
    name = "cc_wrapper",
    srcs = ["cc_wrapper.sh"],
)

filegroup(
    name = "compiler_deps",
    srcs = glob(["extra_tools/**"]) + [":cc_wrapper"],
)

load(
    ":cc_toolchain_config.bzl", "cc_toolchain_config"
    )

cc_toolchain_config(
    name = "cc-compiler-darwin-config"
    )

cc_toolchain_suite(
    name = "toolchain",
    toolchains = {
        "darwin|compiler": ":cc-compiler-darwin",
        "darwin": ":cc-compiler-darwin",
    },
)

cc_toolchain(
    name = "cc-compiler-darwin",
    all_files = ":compiler_deps",
    compiler_files = ":compiler_deps",
    toolchain_identifier = "local",
    toolchain_config = ":cc-compiler-darwin-config",
    dwp_files = ":empty",
    linker_files = ":compiler_deps",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)
