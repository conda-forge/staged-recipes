load("@rules_cc//cc:cc_library.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

[cc_library(
    name = n,
) for n in [
    "config",
    "core_headers",
    "base_internal",
    "dynamic_annotations",
    "atomic_hook",
    "errno_saver",
    "fast_type_id",
    "pretty_function",
    "no_destructor",
]]

cc_library(
  name = "log_severity",
  linkopts = ["-labsl_log_severity"],
)

cc_library(
    name = "throw_delegate",
    linkopts = ["-labsl_throw_delegate"],
    deps = [
        ":raw_logging_internal",
    ],
)

cc_library(
    name = "raw_logging_internal",
    linkopts = ["-labsl_raw_logging_internal"],
    deps = [
        ":log_severity",
    ],
)

cc_library(
    name = "base",
    linkopts = [
        "-labsl_base",
        "-pthread",
    ],
    deps = [
        ":log_severity",
        ":raw_logging_internal",
        ":spinlock_wait",
    ],
)

cc_library(
    name = "nullability",
    deps = [
        ":core_headers",
        "//absl/meta:type_traits",
    ],
)

cc_library(
    name = "malloc_internal",
    linkopts = [
        "-labsl_malloc_internal",
        "-pthread",
    ],
    deps = [
        ":base",
        ":raw_logging_internal",
    ],
)

cc_library(
    name = "endian",
    deps = [
        ":base",
    ],
)

cc_library(
    name = "spinlock_wait",
    linkopts = ["-labsl_spinlock_wait"],
)

cc_library(
    name = "exponential_biased",
    linkopts = ["-labsl_exponential_biased"],
    visibility = [
        "//absl:__subpackages__",
    ],
)
