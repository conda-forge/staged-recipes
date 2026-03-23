load("@rules_cc//cc:cc_library.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "globals",
    linkopts = [
        "-labsl_log_globals",
        "-labsl_log_severity",
        "-labsl_raw_logging_internal",
        "-labsl_vlog_config_internal",
    ],
    deps = [
        ":log",
        "//absl/base:config",
        "//absl/base:core_headers",
        "//absl/hash",
        "//absl/strings",
    ],
)

cc_library(
    name = "log",
    linkopts = [
        "-labsl_vlog_config_internal",
        "-labsl_log_internal_conditions",
        "-labsl_log_internal_check_op",
        "-labsl_log_internal_message",
        "-labsl_log_internal_nullguard",
        "-labsl_synchronization",
        "-labsl_kernel_timeout_internal",
        "-labsl_cordz_info",
        "-labsl_cordz_functions",
        "-labsl_log_internal_globals"
    ],
)

cc_library(
    name = "absl_log",
    deps = [
        ":log",
    ]
)

cc_library(
    name = "initialize",
    linkopts = [
        "-labsl_log_initialize",
    ],
)

cc_library(
    name = "absl_check",
    linkopts = [
        "-labsl_vlog_config_internal",
        "-labsl_log_internal_check_op",
        "-labsl_log_internal_message",
        "-labsl_log_internal_nullguard",
    ],
)

alias(
    name = "check",
    actual = "absl_check",
)

alias(
    name = "die_if_null",
    actual = "absl_check",
)
