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
    name = "cc-compiler-target-config"
)

load(
    ":cc_toolchain_build_config.bzl", build_cc_toolchain_config = "cc_toolchain_config"
)
build_cc_toolchain_config(
    name = "cc-compiler-build-config"
)

toolchains = {
    "BUILD_CPU|compiler": ":cc-compiler-build",
    "BUILD_CPU": ":cc-compiler-build",
}
toolchains["TARGET_CPU|compiler"] = ":cc-compiler-target"
toolchains["TARGET_CPU"] = ":cc-compiler-target"
cc_toolchain_suite(
    name = "toolchain",
    toolchains = toolchains,
)

cc_toolchain(
    name = "cc-compiler-target",
    all_files = ":compiler_deps",
    compiler_files = ":compiler_deps",
    toolchain_identifier = "local",
    toolchain_config = ":cc-compiler-target-config",
    dwp_files = ":empty",
    linker_files = ":compiler_deps",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)

cc_toolchain(
    name = "cc-compiler-build",
    all_files = ":compiler_deps",
    compiler_files = ":compiler_deps",
    toolchain_identifier = "build",
    toolchain_config = ":cc-compiler-build-config",
    dwp_files = ":empty",
    linker_files = ":compiler_deps",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)
